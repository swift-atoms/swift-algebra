import Testing

@testable import Algebra

private enum Monoid {}

extension Monoid {
    @Suite
    struct Test {
    }
}

extension Monoid.Test {
    @Test
    func `init stores identity and combining`() {
        let monoid = Algebra.Monoid<Int>(identity: 0, combining: { $0 &+ $1 })
        #expect(monoid.identity == 0)
        #expect(monoid.combining(3, 4) == 7)
    }

    @Test
    func `left identity holds`() {
        let monoid = Algebra.Monoid<Int>(identity: 0, combining: { $0 &+ $1 })
        #expect(monoid.combining(monoid.identity, 42) == 42)
    }

    @Test
    func `right identity holds`() {
        let monoid = Algebra.Monoid<Int>(identity: 0, combining: { $0 &+ $1 })
        #expect(monoid.combining(42, monoid.identity) == 42)
    }

    @Test
    func `semigroup projection preserves operation`() {
        let monoid = Algebra.Monoid<Int>(identity: 0, combining: { $0 &+ $1 })
        let semigroup = monoid.semigroup
        #expect(semigroup.combining(3, 4) == monoid.combining(3, 4))
    }

    @Test
    func `magma projection preserves operation`() {
        let monoid = Algebra.Monoid<Int>(identity: 0, combining: { $0 &+ $1 })
        let magma = monoid.magma
        #expect(magma.combining(3, 4) == monoid.combining(3, 4))
    }
}

extension Monoid.Test {
    @Test
    func `multiplicative monoid identity is one`() {
        let monoid = Algebra.Monoid<Int>(identity: 1, combining: { $0 &* $1 })
        #expect(monoid.combining(monoid.identity, 42) == 42)
        #expect(monoid.combining(42, monoid.identity) == 42)
    }

    @Test
    func `string monoid with empty identity`() {
        let monoid = Algebra.Monoid<String>(identity: "", combining: { $0 + $1 })
        #expect(monoid.combining(monoid.identity, "hello") == "hello")
        #expect(monoid.combining("hello", monoid.identity) == "hello")
    }
}
