extension Type {
    public enum Construction {
    }
}

extension Type.Construction {
    public static func predicate(on value: Expression) -> Expression {
        .exponential(domain: value, codomain: .sum([.unit, .unit]))
    }

    public static func reader(environment: Expression, value: Expression) -> Expression {
        .exponential(domain: environment, codomain: value)
    }

    public static func state(_ state: Expression, value: Expression) -> Expression {
        .exponential(domain: state, codomain: .product([value, state]))
    }

    public static func writer(output: Expression, value: Expression) -> Expression {
        .product([value, output])
    }

    public static func exception(failure: Expression, value: Expression) -> Expression {
        .sum([failure, value])
    }

    public static func continuation(answer: Expression, value: Expression) -> Expression {
        .exponential(domain: .exponential(domain: value, codomain: answer), codomain: answer)
    }

    public static func retaining(
        state: Expression,
        failure: Expression,
        value: Expression
    ) -> Expression {
        .exponential(domain: state, codomain: .product([.sum([failure, value]), state]))
    }

    public static func discarding(
        state: Expression,
        failure: Expression,
        value: Expression
    ) -> Expression {
        .exponential(domain: state, codomain: .sum([failure, .product([value, state])]))
    }
}

extension Type.Record {
    public func eliminator(returning result: Type.Expression) -> Type.Expression {
        .product(fields.map { .exponential(domain: $0.type, codomain: result) })
    }
    public var replacement: Type.Expression { alternatives }
    public var transformations: Type.Expression {
        .sum(fields.map { .exponential(domain: $0.type, codomain: $0.type) })
    }
    public var indices: Type.Expression { .sum(fields.map { _ in .unit }) }
    public func context(at label: String) throws -> Selection { try excluding([label]) }
}
