import Testing

@testable import Algebra_Lattice

@Suite
struct `Algebra.Lattice Tests` {
    @Suite struct Unit {}
    @Suite struct Laws {}
    @Suite struct Bounds {}
    @Suite struct PartialOrder {}
}

extension `Algebra.Lattice Tests`.Unit {

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

extension `Algebra.Lattice Tests`.Laws {

    static var l: Algebra.Lattice<Int> {
        .minMax(bottom: .min, top: .max)
    }

    @Test
    func `join and meet are idempotent`() {
        for a in [0, 1, 42, -7, Int.max] {
            #expect(`Algebra.Lattice Tests`.Laws.l.join(a, a) == a)
            #expect(`Algebra.Lattice Tests`.Laws.l.meet(a, a) == a)
        }
    }

    @Test
    func `join and meet are commutative`() {
        #expect(
            `Algebra.Lattice Tests`.Laws.l.join(3, 7) == `Algebra.Lattice Tests`.Laws.l.join(7, 3)
        )
        #expect(
            `Algebra.Lattice Tests`.Laws.l.meet(3, 7) == `Algebra.Lattice Tests`.Laws.l.meet(7, 3)
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

extension `Algebra.Lattice Tests`.Bounds {

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

extension `Algebra.Lattice Tests`.PartialOrder {

    @Test
    func `leq matches the numeric order for the min/max lattice`() {
        let l = Algebra.Lattice<Int>.minMax(bottom: .min, top: .max)
        #expect(l.leq(3, 7) == true)
        #expect(l.leq(7, 3) == false)
        #expect(l.leq(5, 5) == true)
    }
}
