extension Algebra.Law {

    @frozen
    public struct Violation<Element> {

        public var law: String

        public var elements: [Element]

        public var lhs: Element

        public var rhs: Element

        @inlinable
        public init(law: String, elements: [Element], lhs: Element, rhs: Element) {
            self.law = law
            self.elements = elements
            self.lhs = lhs
            self.rhs = rhs
        }
    }
}

extension Algebra.Law.Violation: Sendable where Element: Sendable {}
