import Testing

@testable import Algebra

private enum Commutative {}

extension Commutative {
    @Suite
    struct `Commutative rings preserve ring operations and commutative multiplication` {
    }
}

extension Commutative.`Commutative rings preserve ring operations and commutative multiplication` {
    static var intCommutativeRing: Algebra.Ring<Int>.Commutative {
        .init(
            ring: .init(
                additive: .init(
                    group: .init(
                        identity: 0,
                        combining: { $0 &+ $1 },
                        inverting: { 0 &- $0 }
                    )
                ),
                multiplicative: .init(identity: 1, combining: { $0 &* $1 })
            )
        )
    }

    @Test
    func `init wraps ring`() {
        let commutative = Self.intCommutativeRing
        #expect(commutative.ring.zero == 0)
        #expect(commutative.ring.one == 1)
    }

    @Test
    func `zero delegates to underlying ring`() {
        let commutative = Self.intCommutativeRing
        #expect(commutative.zero == 0)
    }

    @Test
    func `one delegates to underlying ring`() {
        let commutative = Self.intCommutativeRing
        #expect(commutative.one == 1)
    }

    @Test
    func `adding delegates to underlying ring`() {
        let commutative = Self.intCommutativeRing
        #expect(commutative.adding(3, 4) == 7)
    }

    @Test
    func `negating delegates to underlying ring`() {
        let commutative = Self.intCommutativeRing
        #expect(commutative.negating(5) == -5)
    }

    @Test
    func `multiplying delegates to underlying ring`() {
        let commutative = Self.intCommutativeRing
        #expect(commutative.multiplying(3, 4) == 12)
    }

    @Test
    func `The underlying commutative ring exposes additive identity zero`() {
        let commutative = Self.intCommutativeRing
        #expect(commutative.ring.additive.identity == 0)
    }

    @Test
    func `A commutative ring projects to a multiplicative monoid with identity one`() {
        let commutative = Self.intCommutativeRing
        let monoid = Algebra.Monoid<Int>.Commutative(commutative)
        #expect(monoid.identity == 1)
    }
}

extension Commutative.`Commutative rings preserve ring operations and commutative multiplication` {
    @Test
    func `multiplicative commutativity holds`() {
        let commutative = Commutative.`Commutative rings preserve ring operations and commutative multiplication`.intCommutativeRing
        #expect(commutative.multiplying(3, 4) == commutative.multiplying(4, 3))
    }
}
