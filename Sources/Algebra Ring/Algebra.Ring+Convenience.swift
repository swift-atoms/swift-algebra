import Algebra_Group

extension Algebra.Ring {

    @inlinable
    public var zero: Element { additive.identity }

    @inlinable
    public var one: Element { multiplicative.identity }

    @inlinable
    public func adding(_ lhs: Element, _ rhs: Element) -> Element {
        additive.combining(lhs, rhs)
    }

    @inlinable
    public func negating(_ element: Element) -> Element {
        additive.inverting(element)
    }

    @inlinable
    public func multiplying(_ lhs: Element, _ rhs: Element) -> Element {
        multiplicative.combining(lhs, rhs)
    }

    @inlinable
    public func subtracting(_ lhs: Element, _ rhs: Element) -> Element {
        additive.combining(lhs, additive.inverting(rhs))
    }
}

extension Algebra.Ring.Commutative {

    @inlinable
    public var zero: Element { ring.zero }

    @inlinable
    public var one: Element { ring.one }

    @inlinable
    public func adding(_ lhs: Element, _ rhs: Element) -> Element {
        ring.adding(lhs, rhs)
    }

    @inlinable
    public func negating(_ element: Element) -> Element {
        ring.negating(element)
    }

    @inlinable
    public func multiplying(_ lhs: Element, _ rhs: Element) -> Element {
        ring.multiplying(lhs, rhs)
    }

    @inlinable
    public func subtracting(_ lhs: Element, _ rhs: Element) -> Element {
        ring.subtracting(lhs, rhs)
    }
}
