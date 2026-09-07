
extension Algebra {

    @frozen
    public struct Semigroup<Element: ~Copyable & ~Escapable> {

        public var combining: (borrowing Element, borrowing Element) -> Element

        @inlinable
        public init(
            combining: @escaping (borrowing Element, borrowing Element) -> Element
        ) {
            self.combining = combining
        }

    }
}

extension Algebra.Semigroup where Element: ~Copyable & ~Escapable {
    @inlinable
    public func callAsFunction(
        _ lhs: borrowing Element,
        _ rhs: borrowing Element
    ) -> Element {
        combining(lhs, rhs)
    }
}

extension Algebra.Semigroup {

    @inlinable
    public var magma: Algebra.Magma<Element> { .init(self) }
}
