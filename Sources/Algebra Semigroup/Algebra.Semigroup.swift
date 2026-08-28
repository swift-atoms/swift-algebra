import Algebra_Primitive

extension Algebra {

    @frozen
    public struct Semigroup<Element> {

        public var combining: (Element, Element) -> Element

        @inlinable
        public init(
            combining: @escaping (Element, Element) -> Element
        ) {
            self.combining = combining
        }

        @inlinable
        public func callAsFunction(_ lhs: Element, _ rhs: Element) -> Element {
            combining(lhs, rhs)
        }
    }
}

extension Algebra.Semigroup: @unchecked Sendable where Element: Sendable {}
