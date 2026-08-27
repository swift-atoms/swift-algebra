extension Algebra.Monoid {

    @inlinable
    public init(
        _ abelian: Algebra.Group<Element>.Abelian
    ) {
        self.init(identity: abelian.group.identity, combining: abelian.group.combining)
    }
}

extension Algebra.Monoid.Commutative {

    @inlinable
    public init(
        _ abelian: Algebra.Group<Element>.Abelian
    ) {
        self.init(monoid: .init(abelian))
    }
}

extension Algebra.Group.Abelian {

    @inlinable
    public var identity: Element { group.identity }

    @inlinable
    public var combining: (Element, Element) -> Element { group.combining }

    @inlinable
    public var inverting: (Element) -> Element { group.inverting }

    @inlinable
    public var monoid: Algebra.Monoid<Element> { .init(self) }

    @inlinable
    public var commutative: Algebra.Monoid<Element>.Commutative { .init(self) }

    @inlinable
    public func callAsFunction(_ lhs: Element, _ rhs: Element) -> Element {
        combining(lhs, rhs)
    }
}
