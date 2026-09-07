
extension Algebra.Semigroup {

    @inlinable
    public init(_ monoid: Algebra.Monoid<Element>) {
        self.init(combining: monoid.combining)
    }
}
