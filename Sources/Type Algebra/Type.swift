/// A language of type descriptions. This module does not import a compiler or a syntax library.
/// Descriptions are not Swift metatypes. Atoms are opaque, explicitly identified sorts.
public enum Type {
    public struct Atom: Hashable, Sendable {
        public let scope: [String]
        public let name: String
        public init(_ name: String, scope: [String] = []) { self.name = name; self.scope = scope }
    }

    public struct Variable: Hashable, Sendable {
        public let name: String
        public init(_ name: String) { self.name = name }
    }

    public struct Failure: Error, Equatable, Sendable, CustomStringConvertible {
        public let description: String
        public init(_ description: String) { self.description = description }
    }

    public struct Polarity: OptionSet, Hashable, Sendable {
        public let rawValue: Int
        public init(rawValue: Int) { self.rawValue = rawValue }
        public static let positive = Self(rawValue: 1)
        public static let negative = Self(rawValue: 2)
        public static let unknown = Self(rawValue: 4)
        public var reversed: Self {
            var result: Self = []
            if contains(.positive) { result.insert(.negative) }
            if contains(.negative) { result.insert(.positive) }
            if contains(.unknown) { result.insert(.unknown) }
            return result
        }
    }

    public indirect enum Expression: Hashable, Sendable {
        case zero
        case unit
        case atom(Atom)
        case variable(Variable)
        case sum([Expression])
        case product([Expression])
        case exponential(domain: Expression, codomain: Expression)
        /// Finite lists, the free monoid. Not a finite polynomial in its element variable.
        case list(Expression)
        /// A named effect constructor; this declaration alone asserts no functor or monad laws.
        case effect(Atom, Expression)
        /// A constructor whose action is not supplied. Occurrences must not disappear as constants.
        case opaque(Atom, Set<Variable>)

        public static func optional(_ value: Self) -> Self { .sum([.unit, value]) }

        public func polarity(of variable: Variable) -> Polarity {
            switch self {
            case .zero, .unit, .atom: return []
            case .variable(let found): return found == variable ? .positive : []
            case .sum(let values), .product(let values):
                return values.reduce([]) { $0.union($1.polarity(of: variable)) }
            case .exponential(let domain, let codomain):
                return domain.polarity(of: variable).reversed.union(codomain.polarity(of: variable))
            case .list(let value): return value.polarity(of: variable)
            case .effect(_, let value): return value.variables.contains(variable) ? .unknown : []
            case .opaque(_, let variables): return variables.contains(variable) ? .unknown : []
            }
        }

        public var variables: Set<Variable> {
            switch self {
            case .zero, .unit, .atom: return []
            case .variable(let value): return [value]
            case .sum(let values), .product(let values): return values.reduce([]) { $0.union($1.variables) }
            case .exponential(let domain, let codomain): return domain.variables.union(codomain.variables)
            case .list(let value), .effect(_, let value): return value.variables
            case .opaque(_, let values): return values
            }
        }

        public var containsExponential: Bool {
            switch self {
            case .exponential: return true
            case .sum(let values), .product(let values): return values.contains { $0.containsExponential }
            case .list(let value), .effect(_, let value): return value.containsExponential
            default: return false
            }
        }

        /// Carrier formation uses strict positivity, not merely an even number of variance reversals.
        /// A double contravariant function space has a covariant action but need not admit a fixed point.
        public func isStrictlyPositive(in variable: Variable) -> Bool {
            switch self {
            case .zero, .unit, .atom, .variable: return true
            case .sum(let values), .product(let values): return values.allSatisfy { $0.isStrictlyPositive(in: variable) }
            case .list(let value): return value.isStrictlyPositive(in: variable)
            case .exponential(let domain, let codomain):
                return !domain.variables.contains(variable) && codomain.isStrictlyPositive(in: variable)
            case .effect(_, let value): return !value.variables.contains(variable)
            case .opaque(_, let variables): return !variables.contains(variable)
            }
        }

        /// Eligibility for finite structural traversal. Lists are traversable although not finite polynomials.
        public var isTraversable: Bool {
            switch self {
            case .zero, .unit, .atom, .variable: return true
            case .sum(let values), .product(let values): return values.allSatisfy(\.isTraversable)
            case .list(let value): return value.isTraversable
            case .exponential, .effect, .opaque: return false
            }
        }

        public func substituting(_ substitutions: [Variable: Self]) throws -> Self {
            switch self {
            case .variable(let value): return substitutions[value] ?? self
            case .sum(let values): return .sum(try values.map { try $0.substituting(substitutions) })
            case .product(let values): return .product(try values.map { try $0.substituting(substitutions) })
            case .exponential(let domain, let codomain):
                return .exponential(domain: try domain.substituting(substitutions), codomain: try codomain.substituting(substitutions))
            case .list(let value): return .list(try value.substituting(substitutions))
            case .effect(let effect, let value): return .effect(effect, try value.substituting(substitutions))
            case .opaque(_, let variables):
                guard variables.isDisjoint(with: substitutions.keys) else { throw Failure("substitution through an opaque constructor requires an explicit interpretation") }
                return self
            default: return self
            }
        }
    }
}
