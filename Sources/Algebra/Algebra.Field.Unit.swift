extension Algebra.Field {

    @frozen
    public struct Unit {

        public var element: Element

        public var inverse: Element

        @usableFromInline
        internal init(element: Element, inverse: Element) {
            self.element = element
            self.inverse = inverse
        }
    }
}

extension Algebra.Field.Unit: Sendable where Element: Sendable {}
