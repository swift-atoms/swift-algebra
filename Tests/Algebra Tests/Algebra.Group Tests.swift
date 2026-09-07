import Testing

@testable import Algebra

private enum Group {}

extension Group {
    @Suite
    struct Test {
    }
}

extension Group.Test {
    @Test
    func `init stores identity, combining, and inverting`() {
        let group = Algebra.Group<Int>(
            identity: 0,
            combining: { $0 &+ $1 },
            inverting: { 0 &- $0 }
        )
        #expect(group.identity == 0)
        #expect(group.combining(3, 4) == 7)
        #expect(group.inverting(5) == -5)
    }

    @Test
    func `left inverse produces identity`() {
        let group = Algebra.Group<Int>(
            identity: 0,
            combining: { $0 &+ $1 },
            inverting: { 0 &- $0 }
        )
        let a = 42
        #expect(group.combining(group.inverting(a), a) == group.identity)
    }

    @Test
    func `right inverse produces identity`() {
        let group = Algebra.Group<Int>(
            identity: 0,
            combining: { $0 &+ $1 },
            inverting: { 0 &- $0 }
        )
        let a = 42
        #expect(group.combining(a, group.inverting(a)) == group.identity)
    }

    @Test
    func `monoid projection preserves identity and combining`() {
        let group = Algebra.Group<Int>(
            identity: 0,
            combining: { $0 &+ $1 },
            inverting: { 0 &- $0 }
        )
        let monoid = group.monoid
        #expect(monoid.identity == group.identity)
        #expect(monoid.combining(3, 4) == group.combining(3, 4))
    }

    @Test
    func `semigroup projection preserves combining`() {
        let group = Algebra.Group<Int>(
            identity: 0,
            combining: { $0 &+ $1 },
            inverting: { 0 &- $0 }
        )
        let semigroup = group.semigroup
        #expect(semigroup.combining(3, 4) == group.combining(3, 4))
    }

    @Test
    func `magma projection preserves combining`() {
        let group = Algebra.Group<Int>(
            identity: 0,
            combining: { $0 &+ $1 },
            inverting: { 0 &- $0 }
        )
        let magma = group.magma
        #expect(magma.combining(3, 4) == group.combining(3, 4))
    }
}

extension Group.Test {
    @Test
    func `double inverse returns original`() {
        let group = Algebra.Group<Int>(
            identity: 0,
            combining: { $0 &+ $1 },
            inverting: { 0 &- $0 }
        )
        let a = 42
        #expect(group.inverting(group.inverting(a)) == a)
    }

    @Test
    func `identity is its own inverse`() {
        let group = Algebra.Group<Int>(
            identity: 0,
            combining: { $0 &+ $1 },
            inverting: { 0 &- $0 }
        )
        #expect(group.inverting(group.identity) == group.identity)
    }
}
