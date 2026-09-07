import Testing

@testable import Algebra

private enum Semiring {}

extension Semiring {
    @Suite
    struct `Semirings preserve additive and multiplicative operations and laws` {
    }
}

extension Semiring.`Semirings preserve additive and multiplicative operations and laws` {

    static var boolSemiring: Algebra.Semiring<Bool> {
        .init(
            additive: .init(monoid: .init(identity: false, combining: { $0 || $1 })),
            multiplicative: .init(identity: true, combining: { $0 && $1 })
        )
    }
}

extension Semiring.`Semirings preserve additive and multiplicative operations and laws` {
    @Test
    func `init stores additive and multiplicative structures`() {
        let sr = Semiring.`Semirings preserve additive and multiplicative operations and laws`.boolSemiring
        #expect(sr.additive.identity == false)
        #expect(sr.multiplicative.identity == true)
    }

    @Test
    func `zero returns additive identity`() {
        let sr = Semiring.`Semirings preserve additive and multiplicative operations and laws`.boolSemiring
        #expect(sr.zero == false)
    }

    @Test
    func `one returns multiplicative identity`() {
        let sr = Semiring.`Semirings preserve additive and multiplicative operations and laws`.boolSemiring
        #expect(sr.one == true)
    }

    @Test
    func `adding delegates to additive monoid`() {
        let sr = Semiring.`Semirings preserve additive and multiplicative operations and laws`.boolSemiring
        #expect(sr.adding(false, false) == false)
        #expect(sr.adding(false, true) == true)
        #expect(sr.adding(true, false) == true)
        #expect(sr.adding(true, true) == true)
    }

    @Test
    func `multiplying delegates to multiplicative monoid`() {
        let sr = Semiring.`Semirings preserve additive and multiplicative operations and laws`.boolSemiring
        #expect(sr.multiplying(true, true) == true)
        #expect(sr.multiplying(true, false) == false)
        #expect(sr.multiplying(false, true) == false)
        #expect(sr.multiplying(false, false) == false)
    }
}

extension Semiring.`Semirings preserve additive and multiplicative operations and laws` {
    @Test
    func `distributivity left holds`() {
        let sr = Semiring.`Semirings preserve additive and multiplicative operations and laws`.boolSemiring
        for a in [true, false] {
            for b in [true, false] {
                for c in [true, false] {
                    let lhs = sr.multiplying(a, sr.adding(b, c))
                    let rhs = sr.adding(sr.multiplying(a, b), sr.multiplying(a, c))
                    #expect(lhs == rhs)
                }
            }
        }
    }

    @Test
    func `distributivity right holds`() {
        let sr = Semiring.`Semirings preserve additive and multiplicative operations and laws`.boolSemiring
        for a in [true, false] {
            for b in [true, false] {
                for c in [true, false] {
                    let lhs = sr.multiplying(sr.adding(a, b), c)
                    let rhs = sr.adding(sr.multiplying(a, c), sr.multiplying(b, c))
                    #expect(lhs == rhs)
                }
            }
        }
    }

    @Test
    func `zero annihilates under multiplication`() {
        let sr = Semiring.`Semirings preserve additive and multiplicative operations and laws`.boolSemiring
        for a in [true, false] {
            #expect(sr.multiplying(sr.zero, a) == sr.zero)
            #expect(sr.multiplying(a, sr.zero) == sr.zero)
        }
    }
}

private enum Commutative {}

extension Commutative {
    @Suite
    struct `Commutative semirings delegate their operations to the underlying semiring` {
    }
}

extension Commutative.`Commutative semirings delegate their operations to the underlying semiring` {
    static var commutative: Algebra.Semiring<Bool>.Commutative {
        .init(semiring: Semiring.`Semirings preserve additive and multiplicative operations and laws`.boolSemiring)
    }

    @Test
    func `init stores semiring`() {
        let csr = Self.commutative
        #expect(csr.semiring.zero == false)
        #expect(csr.semiring.one == true)
    }

    @Test
    func `convenience delegates to underlying semiring`() {
        let csr = Self.commutative
        #expect(csr.zero == false)
        #expect(csr.one == true)
        #expect(csr.adding(true, false) == true)
        #expect(csr.multiplying(true, false) == false)
    }
}

extension Semiring.`Semirings preserve additive and multiplicative operations and laws` {
    @Test
    func `commutative monoid from semiring preserves additive identity`() {
        let sr = Semiring.`Semirings preserve additive and multiplicative operations and laws`.boolSemiring
        let monoid = Algebra.Monoid<Bool>.Commutative(sr)
        #expect(monoid.identity == false)
    }

    @Test
    func `commutative monoid from semiring preserves additive combining`() {
        let sr = Semiring.`Semirings preserve additive and multiplicative operations and laws`.boolSemiring
        let monoid = Algebra.Monoid<Bool>.Commutative(sr)
        #expect(monoid.combining(false, true) == true)
        #expect(monoid.combining(false, false) == false)
    }
}
