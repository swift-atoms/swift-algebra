import Algebra_Ring

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
