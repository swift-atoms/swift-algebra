import Algebra_Monoid

extension Algebra {

    @frozen
    public struct Group<Element> {

        public var identity: Element

        public var combining: (borrowing Element, borrowing Element) -> Element

        public var inverting: (borrowing Element) -> Element

        @inlinable
        public init(
            identity: Element,
            combining: @escaping (borrowing Element, borrowing Element) -> Element,
            inverting: @escaping (borrowing Element) -> Element
        ) {
            self.identity = identity
            self.combining = combining
            self.inverting = inverting
        }

        @inlinable
        public func callAsFunction(
            _ lhs: borrowing Element,
            _ rhs: borrowing Element
        ) -> Element {
            combining(lhs, rhs)
        }
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
