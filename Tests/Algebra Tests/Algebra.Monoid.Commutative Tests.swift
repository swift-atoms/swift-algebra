import Testing

@testable import Algebra

private enum Commutative {}

extension Commutative {
    @Suite
    struct `Commutative monoids preserve identities and commutative combination` {
    }
}

extension Commutative.`Commutative monoids preserve identities and commutative combination` {
    @Test
    func `init wraps monoid`() {
        let monoid = Algebra.Monoid<Int>(identity: 0, combining: { $0 &+ $1 })
        let commutative = Algebra.Monoid<Int>.Commutative(monoid: monoid)
        #expect(commutative.identity == 0)
        #expect(commutative.combining(3, 4) == 7)
    }

    @Test
    func `identity delegates to underlying monoid`() {
        let monoid = Algebra.Monoid<Int>(identity: 0, combining: { $0 &+ $1 })
        let commutative = Algebra.Monoid<Int>.Commutative(monoid: monoid)
        #expect(commutative.identity == monoid.identity)
    }

    @Test
    func `combining delegates to underlying monoid`() {
        let monoid = Algebra.Monoid<Int>(identity: 0, combining: { $0 &+ $1 })
        let commutative = Algebra.Monoid<Int>.Commutative(monoid: monoid)
        #expect(commutative.combining(3, 4) == monoid.combining(3, 4))
    }

    @Test
    func `commutativity holds for addition`() {
        let monoid = Algebra.Monoid<Int>(identity: 0, combining: { $0 &+ $1 })
        let commutative = Algebra.Monoid<Int>.Commutative(monoid: monoid)
        #expect(commutative.combining(3, 4) == commutative.combining(4, 3))
    }
}

extension Commutative.`Commutative monoids preserve identities and commutative combination` {
    @Test
    func `Commutative monoid multiplication produces the same result in either order`() {
        let monoid = Algebra.Monoid<Int>(identity: 1, combining: { $0 &* $1 })
        let commutative = Algebra.Monoid<Int>.Commutative(monoid: monoid)
        #expect(commutative.combining(3, 4) == commutative.combining(4, 3))
    }
}
