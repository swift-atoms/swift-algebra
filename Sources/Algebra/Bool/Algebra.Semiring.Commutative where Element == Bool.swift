extension Algebra.Semiring.Commutative where Element == Bool {

    @inlinable
    public init() {
        self.init(
            semiring: .init(
                additive: .init(monoid: .init(identity: false, combining: { $0 || $1 })),
                multiplicative: .init(identity: true, combining: { $0 && $1 })
            )
        )
    }
}
