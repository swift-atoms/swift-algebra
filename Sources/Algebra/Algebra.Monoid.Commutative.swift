extension Algebra.Monoid {

    @frozen
    public struct Commutative {

        public var monoid: Algebra.Monoid<Element>

        @inlinable
        public init(monoid: Algebra.Monoid<Element>) {
            self.monoid = monoid
        }
    }
}

extension Algebra.Monoid.Commutative: Sendable where Element: Sendable {}

extension Algebra.Monoid.Commutative {

    @inlinable
    public var identity: Element { monoid.identity }

    @inlinable
    public var combining: (Element, Element) -> Element { monoid.combining }

    @inlinable
    public func callAsFunction(_ lhs: Element, _ rhs: Element) -> Element {
        combining(lhs, rhs)
    }
}
