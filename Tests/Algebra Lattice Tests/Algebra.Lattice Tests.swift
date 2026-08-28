import Testing

@testable import Algebra_Lattice

private enum Lattice {}

extension Lattice {
    @Suite
    struct Test {
    }
}

extension Lattice.Test {

    @Test
    func `join is max, meet is min for the min/max lattice`() {
        let l = Algebra.Lattice<Int>.minMax(bottom: .min, top: .max)
        #expect(l.join(3, 7) == 7)
        #expect(l.meet(3, 7) == 3)
    }

    @Test
    func `convenience init wires bounds and operations`() {
        let l = Algebra.Lattice<Int>(
            bottom: .min,
            join: { Swift.max($0, $1) },
            top: .max,
            meet: { Swift.min($0, $1) }
        )
        #expect(l.bottom == .min)
        #expect(l.top == .max)
        #expect(l.join(2, 9) == 9)
        #expect(l.meet(2, 9) == 2)
    }
}

extension Lattice.Test {

    static var l: Algebra.Lattice<Int> {
        .minMax(bottom: .min, top: .max)
    }

    @Test
    func `join and meet are idempotent`() {
        for a in [0, 1, 42, -7, Int.max] {
            #expect(Lattice.Test.l.join(a, a) == a)
            #expect(Lattice.Test.l.meet(a, a) == a)
        }
    }

    @Test
    func `join and meet are commutative`() {
        #expect(
            Lattice.Test.l.join(3, 7) == Lattice.Test.l.join(7, 3)
        )
        #expect(
            Lattice.Test.l.meet(3, 7) == Lattice.Test.l.meet(7, 3)
        )
    }

    @Test
    func `absorption holds — a join (a meet b) == a`() {
        let l = Self.l
        for a in [0, 1, 42, -7] {
            for b in [3, 9, -2, 100] {
                #expect(l.join(a, l.meet(a, b)) == a)
                #expect(l.meet(a, l.join(a, b)) == a)
            }
        }
    }
}

extension Lattice.Test {

    @Test
    func `bottom is the join identity`() {
        let l = Algebra.Lattice<Int>.minMax(bottom: .min, top: .max)
        for a in [0, 1, 42, -7, Int.max] {
            #expect(l.join(l.bottom, a) == a)
        }
    }

    @Test
    func `top is the meet identity`() {
        let l = Algebra.Lattice<Int>.minMax(bottom: .min, top: .max)
        for a in [0, 1, 42, -7, Int.min] {
            #expect(l.meet(l.top, a) == a)
        }
    }
}

extension Lattice.Test {

    @Test
    func `leq matches the numeric order for the min/max lattice`() {
        let l = Algebra.Lattice<Int>.minMax(bottom: .min, top: .max)
        #expect(l.leq(3, 7) == true)
        #expect(l.leq(7, 3) == false)
        #expect(l.leq(5, 5) == true)
    }
}
