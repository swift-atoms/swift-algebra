
extension Algebra {

    @frozen
    public struct Magma<Element: ~Copyable & ~Escapable> {

        public var combining: (borrowing Element, borrowing Element) -> Element

        @inlinable
        public init(
            combining: @escaping (borrowing Element, borrowing Element) -> Element
        ) {
            self.combining = combining
        }

    }
}

extension Algebra.Magma where Element: ~Copyable & ~Escapable {
    @inlinable
    public func callAsFunction(
        _ lhs: borrowing Element,
        _ rhs: borrowing Element
    ) -> Element {
        combining(lhs, rhs)
    }
}
