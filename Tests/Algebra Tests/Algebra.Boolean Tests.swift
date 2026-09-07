import Algebra
import Testing

@Suite
struct `Boolean algebra operations agree with their algebraic views` {

    let boolean = Algebra.Boolean<Bool>(
        falsity: false,
        disjunction: { $0 || $1 },
        truth: true,
        conjunction: { $0 && $1 },
        negation: { !$0 }
    )

    @Test
    func `connectives have their Boolean semantics`() {
        #expect(boolean.disjunction(false, true))
        #expect(!boolean.conjunction(true, false))
        #expect(boolean.negation(false))
        #expect(boolean.exclusive(true, false))
        #expect(!boolean.exclusive(true, true))
        #expect(!boolean.implication(true, false))
        #expect(boolean.equivalence(true, true))
    }

    @Test
    func `algebraic views preserve the same operations`() {
        #expect(boolean.lattice.bottom == false)
        #expect(boolean.lattice.top == true)
        #expect(boolean.semiring.adding(false, true))
        #expect(!boolean.semiring.multiplying(true, false))
        #expect(boolean.ring.adding(true, false))
        #expect(!boolean.ring.adding(true, true))
    }
}
