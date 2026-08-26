import Algebra_Monoid

extension Algebra.Semiring {

    @inlinable
    public var zero: Element { additive.identity }

    @inlinable
    public var one: Element { multiplicative.identity }

    @inlinable
    public func adding(_ lhs: Element, _ rhs: Element) -> Element {
        additive.combining(lhs, rhs)
    }

    @inlinable
    public func multiplying(_ lhs: Element, _ rhs: Element) -> Element {
        multiplicative.combining(lhs, rhs)
    }
}

extension Algebra.Semiring.Commutative {

    @inlinable
    public var zero: Element { semiring.zero }

    @inlinable
    public var one: Element { semiring.one }

    @inlinable
    public func adding(_ lhs: Element, _ rhs: Element) -> Element {
        semiring.adding(lhs, rhs)
    }

    @inlinable
    public func multiplying(_ lhs: Element, _ rhs: Element) -> Element {
        semiring.multiplying(lhs, rhs)
    }
}
