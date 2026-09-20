extension Type {
    public struct Operation: Equatable, Sendable {
        public let name: String
        public let input: Expression
        public let output: Expression
        public let effect: Atom?
        public init(_ name: String, input: Expression, output: Expression, effect: Atom? = nil) {
            self.name = name; self.input = input; self.output = output; self.effect = effect
        }
        public var implementation: Expression {
            .exponential(domain: input, codomain: effect.map { .effect($0, output) } ?? output)
        }
        public func continuation(_ result: Expression) -> Expression {
            .product([input, .exponential(domain: output, codomain: result)])
        }
    }

    /// A finite indexed family retains which output belongs to which input.
    public struct Signature: Equatable, Sendable {
        public let operations: [Operation]
        public init(_ operations: [Operation]) throws {
            guard Set(operations.map(\.name)).count == operations.count else { throw Failure("operation identities must be unique") }
            self.operations = operations
        }
        public var implementation: Expression { .product(operations.map(\.implementation)) }
        public var request: Expression { .sum(operations.map(\.input)) }
        public var exchanges: Expression { .sum(operations.map { .product([$0.input, $0.output]) }) }
        public var requests: Expression { .list(request) }
        public func response(to operation: String) throws -> Expression {
            guard let value = operations.first(where: { $0.name == operation }) else { throw Failure("unknown operation `\(operation)`") }
            return value.output
        }
        public func continuation(_ result: Expression) -> Expression { .sum(operations.map { $0.continuation(result) }) }
        public func machine(state: Expression) -> Expression {
            .product(operations.map { operation in
                let outcome = Expression.product([operation.output, state])
                return .exponential(domain: operation.input, codomain: operation.effect.map { .effect($0, outcome) } ?? outcome)
            })
        }
    }

    /// Explicit binding avoids pretending a recursive carrier is a finite expression.
    public struct Recursion: Equatable, Sendable {
        public enum Kind: Equatable, Sendable { case least, greatest }
        public let kind: Kind
        public let variable: Variable
        public let body: Expression
        public init(_ kind: Kind, variable: Variable, body: Expression) throws {
            guard body.isStrictlyPositive(in: variable) else {
                throw Failure("recursive carrier requires a strictly positive, known action in its bound variable")
            }
            self.kind = kind; self.variable = variable; self.body = body
        }
        public static func free(layer: Expression, variable: Variable, returning result: Expression) throws -> Self {
            guard !result.variables.contains(variable) else { throw Failure("free carrier would capture the result variable") }
            return try Self(.least, variable: variable, body: .sum([result, layer]))
        }
        public static func cofree(layer: Expression, variable: Variable, observing result: Expression) throws -> Self {
            guard !result.variables.contains(variable) else { throw Failure("cofree carrier would capture the observation variable") }
            return try Self(.greatest, variable: variable, body: .product([result, layer]))
        }
    }
}
