import Testing

@testable import Algebra

private enum Ring {}

extension Ring {
    @Suite
    struct Test {
    }
}

extension Ring.Test {
    static var intRing: Algebra.Ring<Int> {
        .init(
            additive: .init(
                group: .init(
                    identity: 0,
                    combining: { $0 &+ $1 },
                    inverting: { 0 &- $0 }
                )
            ),
            multiplicative: .init(identity: 1, combining: { $0 &* $1 })
        )
    }

    @Test
    func `init stores additive and multiplicative structures`() {
        let ring = Self.intRing
        #expect(ring.additive.identity == 0)
        #expect(ring.multiplicative.identity == 1)
    }

    @Test
    func `zero returns additive identity`() {
        let ring = Self.intRing
        #expect(ring.zero == 0)
    }

    @Test
    func `one returns multiplicative identity`() {
        let ring = Self.intRing
        #expect(ring.one == 1)
    }

    @Test
    func `adding delegates to additive group`() {
        let ring = Self.intRing
        #expect(ring.adding(3, 4) == 7)
    }

    @Test
    func `negating delegates to additive inverse`() {
        let ring = Self.intRing
        #expect(ring.negating(5) == -5)
    }

    @Test
    func `multiplying delegates to multiplicative monoid`() {
        let ring = Self.intRing
        #expect(ring.multiplying(3, 4) == 12)
    }

    @Test
    func `additive stored property returns abelian group`() {
        let ring = Self.intRing
        #expect(ring.additive.identity == 0)
        #expect(ring.additive.combining(3, 4) == 7)
    }

    @Test
    func `multiplicative stored property returns monoid`() {
        let ring = Self.intRing
        #expect(ring.multiplicative.identity == 1)
        #expect(ring.multiplicative.combining(3, 4) == 12)
    }
}

extension Ring.Test {
    @Test
    func `zero annihilates under multiplication`() {
        let ring = Ring.Test.intRing
        #expect(ring.multiplying(ring.zero, 42) == ring.zero)
        #expect(ring.multiplying(42, ring.zero) == ring.zero)
    }

    @Test
    func `distributivity left holds`() {
        let ring = Ring.Test.intRing
        let a = 2
        let b = 3
        let c = 4

        let lhs = ring.multiplying(a, ring.adding(b, c))
        let rhs = ring.adding(ring.multiplying(a, b), ring.multiplying(a, c))
        #expect(lhs == rhs)
    }

    @Test
    func `distributivity right holds`() {
        let ring = Ring.Test.intRing
        let a = 2
        let b = 3
        let c = 4

        let lhs = ring.multiplying(ring.adding(a, b), c)
        let rhs = ring.adding(ring.multiplying(a, c), ring.multiplying(b, c))
        #expect(lhs == rhs)
    }
}
