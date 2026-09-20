extension Type {
    /// Finite polynomial syntax. Functions, lists and arbitrary effects cannot enter this grammar.
    public indirect enum Polynomial: Hashable, Sendable {
        case zero
        case unit
        case atom(Atom)
        case variable(Variable)
        case sum([Polynomial])
        case product([Polynomial])

        public init(_ expression: Expression) throws {
            switch expression {
            case .zero: self = .zero
            case .unit: self = .unit
            case .atom(let atom): self = .atom(atom)
            case .variable(let variable): self = .variable(variable)
            case .sum(let values): self = .sum(try values.map(Self.init))
            case .product(let values): self = .product(try values.map(Self.init))
            default: throw Failure("requires a finite polynomial; lists, functions, effects and opaque constructors need another construction")
            }
        }

        public var expression: Expression {
            switch self {
            case .zero: return .zero
            case .unit: return .unit
            case .atom(let value): return .atom(value)
            case .variable(let value): return .variable(value)
            case .sum(let values): return .sum(values.map(\.expression))
            case .product(let values): return .product(values.map(\.expression))
            }
        }

        /// The formal derivative, preserving order and multiplicity of positions.
        public func derivative(withRespectTo variable: Variable) -> Self {
            switch self {
            case .zero, .unit, .atom: return .zero
            case .variable(let found): return found == variable ? .unit : .zero
            case .sum(let values): return .sum(values.map { $0.derivative(withRespectTo: variable) })
            case .product(let values):
                return .sum(values.indices.map { hole in
                    .product(values.enumerated().map { index, value in
                        index == hole ? value.derivative(withRespectTo: variable) : value
                    })
                })
            }
        }

        /// Cardinality interpretation over a supplied finite model. Overflow is reported, never wrapped.
        public func cardinality(atoms: [Atom: Int] = [:], variables: [Variable: Int] = [:]) throws -> Int {
            func checked(_ value: Int?) throws -> Int {
                guard let value, value >= 0 else { throw Failure("cardinality requires a nonnegative interpretation for every sort") }
                return value
            }
            switch self {
            case .zero: return 0
            case .unit: return 1
            case .atom(let atom): return try checked(atoms[atom])
            case .variable(let variable): return try checked(variables[variable])
            case .sum(let values), .product(let values):
                let product: Bool
                if case .product = self { product = true } else { product = false }
                return try values.reduce(product ? 1 : 0) { accumulated, value in
                    let next = try value.cardinality(atoms: atoms, variables: variables)
                    let result = product ? accumulated.multipliedReportingOverflow(by: next) : accumulated.addingReportingOverflow(next)
                    guard !result.overflow else { throw Failure("finite cardinality exceeds Int") }
                    return result.partialValue
                }
            }
        }

        /// Each direct occurrence in a sum of products supplies a separate, labelled hole.
        public struct Context: Hashable, Sendable {
            public let alternative: Int
            public let position: Int
            public let remainder: [Polynomial]
        }

        public func contexts(for variable: Variable) throws -> [Context] {
            guard case .sum(let alternatives) = self else { throw Failure("direct contexts require a sum of products") }
            return try alternatives.enumerated().flatMap { alternative, term in
                guard case .product(let fields) = term else { throw Failure("each constructor must be a product") }
                return try fields.enumerated().compactMap { position, field in
                    if field == .variable(variable) {
                        return Context(alternative: alternative, position: position,
                            remainder: fields.enumerated().filter { $0.offset != position }.map(\.element))
                    }
                    guard !field.expression.variables.contains(variable) else {
                        throw Failure("direct contexts do not support nested recursive positions")
                    }
                    return nil
                }
            }
        }
    }
}
