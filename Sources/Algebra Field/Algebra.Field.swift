import Algebra_Ring

extension Algebra {

    @frozen
    public struct Field<Element> {

        public var additive: Algebra.Group<Element>.Abelian

        public var multiplicative: Algebra.Monoid<Element>.Commutative

        public var reciprocal: (Element) throws(Algebra.Field<Element>.Error) -> Element

        @inlinable
        public init(
            additive: Algebra.Group<Element>.Abelian,
            multiplicative: Algebra.Monoid<Element>.Commutative,
            reciprocal: @escaping (Element) throws(Algebra.Field<Element>.Error) -> Element
        ) {
            self.additive = additive
            self.multiplicative = multiplicative
            self.reciprocal = reciprocal
        }
    }
}

extension Algebra.Field: @unchecked Sendable where Element: Sendable {}

extension Algebra.Field {

    public enum Error: Swift.Error, Sendable {

        case nonInvertible
    }
}

extension Algebra.Field {

    @inlinable
    public var zero: Element { additive.identity }

    @inlinable
    public var one: Element { multiplicative.identity }

    @inlinable
    public func adding(_ lhs: Element, _ rhs: Element) -> Element {
        additive.combining(lhs, rhs)
    }

    @inlinable
    public func negating(_ element: Element) -> Element {
        additive.inverting(element)
    }

    @inlinable
    public func subtracting(_ lhs: Element, _ rhs: Element) -> Element {
        additive.combining(lhs, additive.inverting(rhs))
    }

    @inlinable
    public func multiplying(_ lhs: Element, _ rhs: Element) -> Element {
        multiplicative.combining(lhs, rhs)
    }

    @inlinable
    public func dividing(
        _ lhs: Element,
        _ rhs: Element
    ) throws(Algebra.Field<Element>.Error) -> Element {
        multiplying(lhs, try reciprocal(rhs))
    }

    @inlinable
    public func unit(_ element: Element) throws(Algebra.Field<Element>.Error) -> Unit {
        let inv = try reciprocal(element)
        return Unit(element: element, inverse: inv)
    }

    @inlinable
    public var unit: Algebra.Group<Unit>.Abelian {
        let combine = multiplicative.combining
        return .init(
            group: .init(
                identity: Unit(element: multiplicative.identity, inverse: multiplicative.identity),
                combining: { lhs, rhs in
                    Unit(
                        element: combine(lhs.element, rhs.element),
                        inverse: combine(lhs.inverse, rhs.inverse)
                    )
                },
                inverting: { u in
                    Unit(element: u.inverse, inverse: u.element)
                }
            )
        )
    }

    @inlinable
    public var ring: Algebra.Ring<Element>.Commutative {
        .init(
            ring: .init(
                additive: additive,
                multiplicative: multiplicative.monoid
            )
        )
    }
}
