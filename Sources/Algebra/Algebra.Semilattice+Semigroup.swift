extension Algebra.Semigroup {

    @inlinable
    public init(_ semilattice: Algebra.Semilattice<Element>) {
        self.init(combining: semilattice.combining)
    }
}

extension Algebra.Semilattice {

    @inlinable
    public var semigroup: Algebra.Semigroup<Element> { .init(self) }
}
