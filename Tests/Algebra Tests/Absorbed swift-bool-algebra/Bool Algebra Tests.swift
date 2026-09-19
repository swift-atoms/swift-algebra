import Algebra
import Testing

@Suite struct `Bool Algebra Tests` {
    @Suite struct Unit {
        @Suite struct Monoid {}
        @Suite struct Semiring {}
        @Suite struct Semilattice {}
        @Suite struct Lattice {}
    }


}

extension `Bool Algebra Tests`.Unit.Monoid {
    @Test
    func `conjunction monoid has identity true and combines with AND`() {
        let m = Algebra.Monoid<Bool>.conjunction
        #expect(m.identity == true)
        #expect(m.combining(true, true) == true)
        #expect(m.combining(true, false) == false)
        #expect(m.combining(false, false) == false)
    }

    @Test
    func `disjunction monoid has identity false and combines with OR`() {
        let m = Algebra.Monoid<Bool>.disjunction
        #expect(m.identity == false)
        #expect(m.combining(false, false) == false)
        #expect(m.combining(true, false) == true)
        #expect(m.combining(true, true) == true)
    }
}

extension `Bool Algebra Tests`.Unit.Semiring {
    @Test
    func `boolean semiring zero is false and one is true`() {
        let sr = Algebra.Semiring<Bool>.Commutative()
        #expect(sr.zero == false)
        #expect(sr.one == true)
    }

    @Test
    func `boolean semiring adds with OR and multiplies with AND`() {
        let sr = Algebra.Semiring<Bool>.Commutative()
        #expect(sr.adding(false, true) == true)
        #expect(sr.adding(false, false) == false)
        #expect(sr.multiplying(true, true) == true)
        #expect(sr.multiplying(true, false) == false)
    }
}

extension `Bool Algebra Tests`.Unit.Semilattice {
    @Test
    func `disjunction semilattice has identity false`() {
        let or = Algebra.Semilattice<Bool>.disjunction
        #expect(or.identity == false)
        #expect(or.combining(true, false) == true)
        #expect(or.combining(false, false) == false)
    }

    @Test
    func `conjunction semilattice has identity true`() {
        let and = Algebra.Semilattice<Bool>.conjunction
        #expect(and.identity == true)
        #expect(and.combining(true, false) == false)
        #expect(and.combining(true, true) == true)
    }

    @Test
    func `disjunction is idempotent`() {
        let or = Algebra.Semilattice<Bool>.disjunction
        #expect(or.combining(true, true) == true)
        #expect(or.combining(false, false) == false)
    }

    @Test
    func `callAsFunction and join alias combining`() {
        let or = Algebra.Semilattice<Bool>.disjunction
        #expect(or(true, false) == or.combining(true, false))
        let and = Algebra.Semilattice<Bool>.conjunction
        #expect(and.join(true, true) == and.combining(true, true))
    }
}

extension `Bool Algebra Tests`.Unit.Lattice {
    @Test
    func `bool lattice: join is OR, meet is AND`() {
        let l = Algebra.Lattice<Bool>()
        #expect(l.join(false, true) == true)
        #expect(l.join(false, false) == false)
        #expect(l.meet(true, false) == false)
        #expect(l.meet(true, true) == true)
    }

    @Test
    func `bool lattice bounds: bottom false, top true`() {
        let l = Algebra.Lattice<Bool>()
        #expect(l.bottom == false)
        #expect(l.top == true)
    }

    @Test
    func `bool lattice absorption holds`() {
        let l = Algebra.Lattice<Bool>()
        for a in [false, true] {
            for b in [false, true] {
                #expect(l.join(a, l.meet(a, b)) == a)
                #expect(l.meet(a, l.join(a, b)) == a)
            }
        }
    }
}

extension `Bool Algebra Tests`.Unit.Lattice {
    @Test
    func `bool complement laws via native ! over the bool lattice`() {
        let l = Algebra.Lattice<Bool>()
        for a in [false, true] {
            #expect(l.join(a, !a) == l.top)
            #expect(l.meet(a, !a) == l.bottom)
        }
    }

    @Test
    func `bool distributivity over the bool lattice`() {
        let l = Algebra.Lattice<Bool>()
        for a in [false, true] {
            for b in [false, true] {
                for c in [false, true] {
                    #expect(l.meet(a, l.join(b, c)) == l.join(l.meet(a, b), l.meet(a, c)))
                }
            }
        }
    }
}
