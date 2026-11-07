extension Type {
    public struct Isomorphism: Equatable, Sendable {
        public let forward: Morphism
        public let backward: Morphism
    }
}

extension Type.Isomorphism {
    public static func distribution(
        _ factor: Expression,
        over alternatives: [Expression]
    ) -> Self {
        Self(
            forward: .distribution(factor, over: alternatives),
            backward: .factorization(factor, from: alternatives)
        )
    }

    public static func productUnit(_ value: Expression) throws -> Self {
        Self(
            forward: try .projection([.unit, value], at: 1),
            backward: try .pairing(from: value, [.terminal(from: value), .identity(value)])
        )
    }

    public static func sumZero(_ value: Expression) throws -> Self {
        Self(
            forward: try .elimination(to: value, [.initial(to: value), .identity(value)]),
            backward: try .injection([.zero, value], at: 1)
        )
    }

    public static func permutation(of record: Record, order: [String]) throws -> Self {
        guard order.count == record.fields.count else {
            throw Failure("a permutation must include every coordinate")
        }
        let selected = try record.selecting(order)
        let inverse = try selected.record.selecting(record.fields.map(\.name))
        return Self(forward: selected.projection, backward: inverse.projection)
    }
}
