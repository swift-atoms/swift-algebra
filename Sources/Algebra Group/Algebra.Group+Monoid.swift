import Algebra_Monoid

extension Algebra.Monoid {

    @inlinable
    public init(_ group: Algebra.Group<Element>) {
        self.init(identity: group.identity, combining: group.combining)
    }
}

extension Algebra.Semigroup {

    @inlinable
    public init(_ group: Algebra.Group<Element>) {
        self.init(combining: group.combining)
    }
}

extension Algebra.Magma {

    @inlinable
    public init(_ group: Algebra.Group<Element>) {
        self.init(combining: group.combining)
    }
}

extension Algebra.Group {

    @inlinable
    public var monoid: Algebra.Monoid<Element> { .init(self) }

    @inlinable
    public var semigroup: Algebra.Semigroup<Element> { .init(self) }

    @inlinable
    public var magma: Algebra.Magma<Element> { .init(self) }
}
