import Testing

@testable import Algebra

private enum Semilattice {}

extension Semilattice {
    @Suite
    struct Test {
    }
}

extension Semilattice.Test {

    @Test
    func `combining returns expected value`() {
        let maxL = Algebra.Semilattice<Int>(identity: .min, combining: max)
        #expect(maxL.combining(3, 7) == 7)
        #expect(maxL.combining(7, 3) == 7)
    }

    @Test
    func `callAsFunction is alias for combining`() {
        let maxL = Algebra.Semilattice<Int>(identity: .min, combining: max)
        #expect(maxL(3, 7) == maxL.combining(3, 7))
    }

    @Test
    func `join is alias for combining`() {
        let maxL = Algebra.Semilattice<Int>(identity: .min, combining: max)
        #expect(maxL.join(3, 7) == maxL.combining(3, 7))
    }

    @Test
    func `convenience init produces correct semilattice`() {
        let direct = Algebra.Semilattice<Int>(identity: 0, combining: { Swift.max($0, $1) })
        #expect(direct.identity == 0)
        #expect(direct.combining(5, 3) == 5)
    }
}

extension Semilattice.Test {

    static var maxL: Algebra.Semilattice<Int> {
        .init(identity: .min, combining: max)
    }

    @Test
    func `associativity holds`() {
        let a = 3
        let b = 7
        let c = 5
        let lhs = Self.maxL.combining(Self.maxL.combining(a, b), c)
        let rhs = Self.maxL.combining(a, Self.maxL.combining(b, c))
        #expect(lhs == rhs)
    }

    @Test
    func `commutativity holds`() {
        let a = 3
        let b = 7
        #expect(
            Semilattice.Test.maxL.combining(a, b)
                == Semilattice.Test.maxL.combining(b, a)
        )
    }

    @Test
    func `idempotency holds`() {
        for a in [0, 1, 42, -7, Int.max] {
            #expect(Semilattice.Test.maxL.combining(a, a) == a)
        }
    }

    @Test
    func `identity is bottom`() {
        for a in [0, 1, 42, -7, Int.max] {
            #expect(
                Semilattice.Test.maxL.combining(
                    Semilattice.Test.maxL.identity,
                    a
                ) == a
            )
            #expect(
                Semilattice.Test.maxL.combining(
                    a,
                    Semilattice.Test.maxL.identity
                ) == a
            )
        }
    }
}

extension Semilattice.Test {

    @Test
    func `maximum(bottom:) builds correct max-semilattice`() {
        let l = Algebra.Semilattice<Int>.maximum(bottom: .min)
        #expect(l.combining(3, 7) == 7)
        #expect(l.combining(.min, 100) == 100)
        #expect(l.combining(42, 42) == 42)
    }

    @Test
    func `minimum(top:) builds correct min-semilattice`() {
        let l = Algebra.Semilattice<Int>.minimum(top: .max)
        #expect(l.combining(3, 7) == 3)
        #expect(l.combining(.max, 100) == 100)
        #expect(l.combining(42, 42) == 42)
    }
}

extension Semilattice.Test {

    @Test
    func `leq matches Comparable order for max-semilattice`() {
        let l = Algebra.Semilattice<Int>.maximum(bottom: .min)
        #expect(l.leq(3, 7) == true)
        #expect(l.leq(7, 3) == false)
        #expect(l.leq(5, 5) == true)
    }

    @Test
    func `leq matches dual order for min-semilattice`() {
        let l = Algebra.Semilattice<Int>.minimum(top: .max)

        #expect(l.leq(7, 3) == true)
        #expect(l.leq(3, 7) == false)
        #expect(l.leq(5, 5) == true)
    }
}
