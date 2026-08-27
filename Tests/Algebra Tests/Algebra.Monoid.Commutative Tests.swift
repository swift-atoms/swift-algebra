import Testing

@testable import Algebra

@Suite
struct `Algebra.Monoid.Commutative Tests` {
    @Suite struct Unit {}
    @Suite struct EdgeCase {}
}

extension `Algebra.Monoid.Commutative Tests`.Unit {
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

extension `Algebra.Monoid.Commutative Tests`.EdgeCase {
    @Test
    func `multiplicative commutative monoid`() {
        let monoid = Algebra.Monoid<Int>(identity: 1, combining: { $0 &* $1 })
        let commutative = Algebra.Monoid<Int>.Commutative(monoid: monoid)
        #expect(commutative.combining(3, 4) == commutative.combining(4, 3))
    }
}
