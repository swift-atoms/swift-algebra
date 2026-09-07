extension Algebra.Magma {

    @inlinable
    public init(_ monoid: Algebra.Monoid<Element>) {
        self.init(combining: monoid.combining)
    }
}
