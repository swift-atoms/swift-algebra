extension Algebra.Semigroup {

    @inlinable
    public init(_ monoid: Algebra.Monoid<Element>) {
        self.init(combining: monoid.combining)
    }
}

extension Algebra.Magma {

    @inlinable
    public init(_ monoid: Algebra.Monoid<Element>) {
        self.init(combining: monoid.combining)
    }
}

extension Algebra.Monoid {

    @inlinable
    public var semigroup: Algebra.Semigroup<Element> { .init(self) }

    @inlinable
    public var magma: Algebra.Magma<Element> { .init(self) }
}
