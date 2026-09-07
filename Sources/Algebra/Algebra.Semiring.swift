extension Algebra {

    @frozen
    public struct Semiring<Element> {

        public var additive: Algebra.Monoid<Element>.Commutative

        public var multiplicative: Algebra.Monoid<Element>

        @inlinable
        public init(
            additive: Algebra.Monoid<Element>.Commutative,
            multiplicative: Algebra.Monoid<Element>
        ) {
            self.additive = additive
            self.multiplicative = multiplicative
        }
    }
}

extension Algebra.Semiring {

    @inlinable
    public var zero: Element { additive.identity }

    @inlinable
    public var one: Element { multiplicative.identity }

    @inlinable
    public func adding(_ lhs: borrowing Element, _ rhs: borrowing Element) -> Element {
        additive.combining(lhs, rhs)
    }

    @inlinable
    public func multiplying(_ lhs: borrowing Element, _ rhs: borrowing Element) -> Element {
        multiplicative.combining(lhs, rhs)
    }
}

extension Algebra.Semiring.Commutative {

    @inlinable
    public var zero: Element { semiring.zero }

    @inlinable
    public var one: Element { semiring.one }

    @inlinable
    public func adding(_ lhs: borrowing Element, _ rhs: borrowing Element) -> Element {
        semiring.adding(lhs, rhs)
    }

    @inlinable
    public func multiplying(_ lhs: borrowing Element, _ rhs: borrowing Element) -> Element {
        semiring.multiplying(lhs, rhs)
    }
}
