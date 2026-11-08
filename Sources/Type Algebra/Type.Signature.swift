extension Type {
    public struct Operation: Equatable, Sendable {
        public let name: String
        public let input: Expression
        public let output: Expression
        public let effect: Atom?
        public init(_ name: String, input: Expression, output: Expression, effect: Atom? = nil) {
            self.name = name
            self.input = input
            self.output = output
            self.effect = effect
        }
    }

    public struct Signature: Equatable, Sendable {
        public let operations: [Operation]
        public init(_ operations: [Operation]) throws {
            guard Set(operations.map(\.name)).count == operations.count else {
                throw Failure("operation identities must be unique")
            }
            self.operations = operations
        }
    }
}

extension Type.Operation {
    public var implementation: Expression {
        .exponential(domain: input, codomain: effect.map { .effect($0, output) } ?? output)
    }

    public func continuation(_ result: Expression) -> Expression {
        .product([input, .exponential(domain: output, codomain: result)])
    }
}

extension Type.Signature {
    public var implementation: Expression { .product(operations.map(\.implementation)) }

    public var request: Expression { .sum(operations.map(\.input)) }

    public var exchanges: Expression {
        .sum(operations.map { .product([$0.input, $0.output]) })
    }

    public var requests: Expression { .list(request) }

    public func response(to operation: String) throws -> Expression {
        guard let value = operations.first(where: { $0.name == operation }) else {
            throw Failure("unknown operation `\(operation)`")
        }
        return value.output
    }

    public func continuation(_ result: Expression) -> Expression {
        .sum(operations.map { $0.continuation(result) })
    }

    public func machine(state: Expression) -> Expression {
        .product(
            operations.map { operation in
                let outcome = Expression.product([operation.output, state])
                return .exponential(
                    domain: operation.input,
                    codomain: operation.effect.map { .effect($0, outcome) } ?? outcome
                )
            }
        )
    }
}
