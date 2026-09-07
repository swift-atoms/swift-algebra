
extension Algebra {

    @frozen
    public struct Ring<Element> {

        public var additive: Algebra.Group<Element>.Abelian

        public var multiplicative: Algebra.Monoid<Element>

        @inlinable
        public init(
            additive: Algebra.Group<Element>.Abelian,
            multiplicative: Algebra.Monoid<Element>
        ) {
            self.additive = additive
            self.multiplicative = multiplicative
        }
    }
}

extension Algebra.Ring {

    @inlinable
    public var zero: Element { additive.identity }

    @inlinable
    public var one: Element { multiplicative.identity }

    @inlinable
    public func adding(_ lhs: borrowing Element, _ rhs: borrowing Element) -> Element {
        additive.combining(lhs, rhs)
    }

    @inlinable
    public func negating(_ element: borrowing Element) -> Element {
        additive.inverting(element)
    }

    @inlinable
    public func multiplying(_ lhs: borrowing Element, _ rhs: borrowing Element) -> Element {
        multiplicative.combining(lhs, rhs)
    }

    @inlinable
    public func subtracting(_ lhs: borrowing Element, _ rhs: borrowing Element) -> Element {
        additive.combining(lhs, additive.inverting(rhs))
    }

    @inlinable
    public var semiring: Algebra.Semiring<Element> {
        .init(
            additive: additive.commutative,
            multiplicative: multiplicative
        )
    }
}
