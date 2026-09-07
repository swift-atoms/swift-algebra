import Testing

@testable import Algebra

private enum Commutative {}

extension Commutative {
    @Suite
    struct Test {
    }
}

extension Commutative.Test {
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

extension Commutative.Test {
    @Test
    func `multiplicative commutative monoid`() {
        let monoid = Algebra.Monoid<Int>(identity: 1, combining: { $0 &* $1 })
        let commutative = Algebra.Monoid<Int>.Commutative(monoid: monoid)
        #expect(commutative.combining(3, 4) == commutative.combining(4, 3))
    }
}
