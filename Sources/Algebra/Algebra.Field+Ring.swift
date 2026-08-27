extension Algebra.Field {

    @inlinable
    public var ring: Algebra.Ring<Element>.Commutative {
        .init(
            ring: .init(
                additive: additive,
                multiplicative: multiplicative.monoid
            )
        )
    }
}

extension Algebra.Ring.Commutative {

    public init(
        _ field: Algebra.Field<Element>
    ) {
        self = .init(
            ring: .init(
                additive: field.additive,
                multiplicative: field.multiplicative.monoid
            )
        )
    }
}
