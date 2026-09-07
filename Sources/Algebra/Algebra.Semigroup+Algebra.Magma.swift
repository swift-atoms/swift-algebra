extension Algebra.Magma {

    @inlinable
    public init(_ semigroup: Algebra.Semigroup<Element>) {
        self.init(combining: semigroup.combining)
    }
}
