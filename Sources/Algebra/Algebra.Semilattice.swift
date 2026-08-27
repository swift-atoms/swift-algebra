extension Algebra {

    @frozen
    public struct Semilattice<Element> {

        public var monoid: Algebra.Monoid<Element>.Commutative

        @inlinable
        public init(monoid: Algebra.Monoid<Element>.Commutative) {
            self.monoid = monoid
        }
    }
}

extension Algebra.Semilattice: Sendable where Element: Sendable {}

extension Algebra.Semilattice {

    @inlinable
    public var identity: Element { monoid.identity }

    @inlinable
    public var combining: (Element, Element) -> Element { monoid.combining }

    @inlinable
    public func callAsFunction(_ lhs: Element, _ rhs: Element) -> Element {
        combining(lhs, rhs)
    }

    @inlinable
    public func join(_ lhs: Element, _ rhs: Element) -> Element {
        combining(lhs, rhs)
    }
}

extension Algebra.Semilattice {

    @inlinable
    public init(
        identity: Element,
        combining: @escaping (Element, Element) -> Element
    ) {
        self.init(monoid: .init(monoid: .init(identity: identity, combining: combining)))
    }
}

extension Algebra.Semilattice {

    @inlinable
    public func leq(_ lhs: Element, _ rhs: Element) -> Bool where Element: Equatable {
        combining(lhs, rhs) == rhs
    }
}
