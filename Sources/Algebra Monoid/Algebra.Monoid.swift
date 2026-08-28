import Algebra_Semigroup

extension Algebra {

    @frozen
    public struct Monoid<Element> {

        public var identity: Element

        public var combining: (Element, Element) -> Element

        @inlinable
        public init(
            identity: Element,
            combining: @escaping (Element, Element) -> Element
        ) {
            self.identity = identity
            self.combining = combining
        }

        @inlinable
        public func callAsFunction(_ lhs: Element, _ rhs: Element) -> Element {
            combining(lhs, rhs)
        }
    }
}

extension Algebra.Monoid: @unchecked Sendable where Element: Sendable {}

extension Algebra.Monoid {

    @inlinable
    public var semigroup: Algebra.Semigroup<Element> { .init(self) }

    @inlinable
    public var magma: Algebra.Magma<Element> { .init(self) }
}
