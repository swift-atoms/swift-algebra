import Algebra_Monoid

extension Algebra {

    @frozen
    public struct Group<Element> {

        public var identity: Element

        public var combining: (Element, Element) -> Element

        public var inverting: (Element) -> Element

        @inlinable
        public init(
            identity: Element,
            combining: @escaping (Element, Element) -> Element,
            inverting: @escaping (Element) -> Element
        ) {
            self.identity = identity
            self.combining = combining
            self.inverting = inverting
        }

        @inlinable
        public func callAsFunction(_ lhs: Element, _ rhs: Element) -> Element {
            combining(lhs, rhs)
        }
    }
}

extension Algebra.Group: @unchecked Sendable where Element: Sendable {}

extension Algebra.Group {

    @inlinable
    public var monoid: Algebra.Monoid<Element> { .init(self) }

    @inlinable
    public var semigroup: Algebra.Semigroup<Element> { .init(self) }

    @inlinable
    public var magma: Algebra.Magma<Element> { .init(self) }
}
