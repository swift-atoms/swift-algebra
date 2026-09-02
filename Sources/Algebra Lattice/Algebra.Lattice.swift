import Algebra_Semilattice

extension Algebra {

    @frozen
    public struct Lattice<Element> {

        public var join: Algebra.Semilattice<Element>

        public var meet: Algebra.Semilattice<Element>

        @inlinable
        public init(
            join: Algebra.Semilattice<Element>,
            meet: Algebra.Semilattice<Element>
        ) {
            self.join = join
            self.meet = meet
        }
    }
}

extension Algebra.Lattice {

    @inlinable
    public var bottom: Element { join.identity }

    @inlinable
    public var top: Element { meet.identity }
}

extension Algebra.Lattice {

    @inlinable
    public init(
        bottom: Element,
        join: @escaping (borrowing Element, borrowing Element) -> Element,
        top: Element,
        meet: @escaping (borrowing Element, borrowing Element) -> Element
    ) {
        self.init(
            join: .init(identity: bottom, combining: join),
            meet: .init(identity: top, combining: meet)
        )
    }
}

extension Algebra.Lattice {

    @inlinable
    public func leq(
        _ lhs: borrowing Element,
        _ rhs: borrowing Element
    ) -> Bool where Element: Equatable {
        join(lhs, rhs) == rhs
    }
}

extension Algebra.Lattice where Element: Comparable {

    @inlinable
    public static func ordered(bottom: Element, top: Element) -> Self {
        .init(
            join: .maximum(bottom: bottom),
            meet: .minimum(top: top)
        )
    }
}
