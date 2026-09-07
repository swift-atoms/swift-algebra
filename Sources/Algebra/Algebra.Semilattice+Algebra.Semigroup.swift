extension Algebra.Semigroup {

    @inlinable
    public init(_ semilattice: Algebra.Semilattice<Element>) {
        self.init(combining: semilattice.combining)
    }
}
