import Algebra_Group
import Algebra_Semiring

extension Algebra.Ring {

    @frozen
    public struct Commutative {

        public var ring: Algebra.Ring<Element>

        @inlinable
        public init(ring: Algebra.Ring<Element>) {
            self.ring = ring
        }
    }
}

extension Algebra.Ring.Commutative {

    @inlinable
    public var additive: Algebra.Group<Element>.Abelian { ring.additive }

    @inlinable
    public var multiplicative: Algebra.Monoid<Element> { ring.multiplicative }

    @inlinable
    public var zero: Element { ring.zero }

    @inlinable
    public var one: Element { ring.one }

    @inlinable
    public func adding(_ lhs: borrowing Element, _ rhs: borrowing Element) -> Element {
        ring.adding(lhs, rhs)
    }

    @inlinable
    public func negating(_ element: borrowing Element) -> Element {
        ring.negating(element)
    }

    @inlinable
    public func multiplying(_ lhs: borrowing Element, _ rhs: borrowing Element) -> Element {
        ring.multiplying(lhs, rhs)
    }

    @inlinable
    public func subtracting(_ lhs: borrowing Element, _ rhs: borrowing Element) -> Element {
        ring.subtracting(lhs, rhs)
    }

    @inlinable
    public var semiring: Algebra.Semiring<Element>.Commutative {
        .init(semiring: ring.semiring)
    }
}
