extension Algebra.Group {

    @frozen
    public struct Abelian {

        public var group: Algebra.Group<Element>

        @inlinable
        public init(group: Algebra.Group<Element>) {
            self.group = group
        }
    }
}

extension Algebra.Group.Abelian {

    @inlinable
    public var identity: Element { group.identity }

    @inlinable
    public var combining: (borrowing Element, borrowing Element) -> Element {
        group.combining
    }

    @inlinable
    public var inverting: (borrowing Element) -> Element { group.inverting }

    @inlinable
    public var monoid: Algebra.Monoid<Element> { .init(self) }

    @inlinable
    public var commutative: Algebra.Monoid<Element>.Commutative { .init(self) }

    @inlinable
    public func callAsFunction(
        _ lhs: borrowing Element,
        _ rhs: borrowing Element
    ) -> Element {
        combining(lhs, rhs)
    }
}
