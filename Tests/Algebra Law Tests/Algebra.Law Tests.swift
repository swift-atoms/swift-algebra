import Testing

@testable import Algebra_Law

extension Algebra.Law {
    @Suite struct Test {
    }
}

extension Algebra.Law.Test {

    static var intSemigroup: Algebra.Semigroup<Int> {
        .init(combining: { $0 &+ $1 })
    }

    static var intMonoid: Algebra.Monoid<Int> {
        .init(identity: 0, combining: { $0 &+ $1 })
    }

    static var intGroup: Algebra.Group<Int> {
        .init(identity: 0, combining: { $0 &+ $1 }, inverting: { 0 &- $0 })
    }

    static var intRing: Algebra.Ring<Int> {
        .init(
            additive: .init(group: intGroup),
            multiplicative: .init(identity: 1, combining: { $0 &* $1 })
        )
    }

    static var intModule: Algebra.Module<Int, Int> {
        .init(
            scalars: intRing,
            vectors: .init(group: intGroup),
            scaling: { $0 &* $1 }
        )
    }

    static var testElements: [Int] { [0, 1, -1, 2, 3] }

    static var brokenSemigroup: Algebra.Semigroup<Int> {
        .init(combining: { $0 - $1 })
    }

    static var brokenMonoid: Algebra.Monoid<Int> {
        .init(identity: 1, combining: { $0 &+ $1 })
    }

    static var brokenGroup: Algebra.Group<Int> {
        .init(identity: 0, combining: { $0 &+ $1 }, inverting: { $0 })
    }

    static var brokenDistributivityRing: Algebra.Ring<Int> {
        .init(
            additive: .init(
                group: .init(
                    identity: 0,
                    combining: { $0 &+ $1 },
                    inverting: { 0 &- $0 }
                )
            ),
            multiplicative: .init(identity: 1, combining: { $0 &+ $1 })
        )
    }

    static var brokenAnnihilationRing: Algebra.Ring<Int> {
        .init(
            additive: .init(
                group: .init(
                    identity: 0,
                    combining: { $0 &+ $1 },
                    inverting: { 0 &- $0 }
                )
            ),
            multiplicative: .init(identity: 1, combining: { _, rhs in rhs })
        )
    }

    static var brokenReciprocalField: Algebra.Field<Bool> {
        .init(
            additive: .init(
                group: .init(
                    identity: false,
                    combining: { $0 != $1 },
                    inverting: { $0 }
                )
            ),
            multiplicative: .init(
                monoid: .init(
                    identity: true,
                    combining: { $0 && $1 }
                )
            ),
            reciprocal: { (_: Bool) throws(Algebra.Field<Bool>.Error) -> Bool in false }
        )
    }
}

extension Algebra.Law.Test {
    @Test
    func `associativity passes for valid semigroup`() {
        let result = Algebra.Law.Associativity.check(
            of: Algebra.Law.Test.intSemigroup,
            over: Algebra.Law.Test.testElements
        )
        #expect(result == nil)
    }

    @Test
    func `identity left passes for valid monoid`() {
        let result = Algebra.Law.Identity.left(
            of: Algebra.Law.Test.intMonoid,
            over: Algebra.Law.Test.testElements
        )
        #expect(result == nil)
    }

    @Test
    func `identity right passes for valid monoid`() {
        let result = Algebra.Law.Identity.right(
            of: Algebra.Law.Test.intMonoid,
            over: Algebra.Law.Test.testElements
        )
        #expect(result == nil)
    }

    @Test
    func `inverse left passes for valid group`() {
        let result = Algebra.Law.Inverse.left(
            of: Algebra.Law.Test.intGroup,
            over: Algebra.Law.Test.testElements
        )
        #expect(result == nil)
    }

    @Test
    func `inverse right passes for valid group`() {
        let result = Algebra.Law.Inverse.right(
            of: Algebra.Law.Test.intGroup,
            over: Algebra.Law.Test.testElements
        )
        #expect(result == nil)
    }

    @Test
    func `commutativity passes for commutative operation`() {
        let result = Algebra.Law.Commutativity.check(
            of: { (a: Int, b: Int) in a &+ b },
            over: Algebra.Law.Test.testElements
        )
        #expect(result == nil)
    }

    @Test
    func `distributivity left passes for valid ring`() {
        let result = Algebra.Law.Distributivity.left(
            of: Algebra.Law.Test.intRing,
            over: Algebra.Law.Test.testElements
        )
        #expect(result == nil)
    }

    @Test
    func `distributivity right passes for valid ring`() {
        let result = Algebra.Law.Distributivity.right(
            of: Algebra.Law.Test.intRing,
            over: Algebra.Law.Test.testElements
        )
        #expect(result == nil)
    }

    @Test
    func `annihilation passes for valid ring`() {
        let result = Algebra.Law.Annihilation.zero(
            of: Algebra.Law.Test.intRing,
            over: Algebra.Law.Test.testElements
        )
        #expect(result == nil)
    }

    @Test
    func `action identity accepts a sequence`() {
        let result = Algebra.Law.Action.identity(
            of: Algebra.Law.Test.intModule,
            over: Algebra.Law.Test.testElements
        )
        #expect(result == nil)
    }

    @Test
    func `scalar distributivity accepts a scalar sequence`() {
        let result = Algebra.Law.Distributivity.scalar(
            of: Algebra.Law.Test.intModule,
            over: Algebra.Law.Test.testElements,
            Algebra.Law.Test.testElements
        )
        #expect(result == nil)
    }
}

extension Algebra.Law.Test {
    @Test
    func `associativity fails for broken semigroup`() {
        let result = Algebra.Law.Associativity.check(
            of: Algebra.Law.Test.brokenSemigroup,
            over: [1, 2, 3]
        )
        #expect(result != nil)
    }

    @Test
    func `identity fails for broken monoid`() {
        let result = Algebra.Law.Identity.left(
            of: Algebra.Law.Test.brokenMonoid,
            over: [0, 2]
        )
        #expect(result != nil)
    }

    @Test
    func `inverse fails for broken group`() {
        let result = Algebra.Law.Inverse.left(
            of: Algebra.Law.Test.brokenGroup,
            over: [1, 2]
        )
        #expect(result != nil)
    }

    @Test
    func `commutativity fails for non-commutative operation`() {
        let result = Algebra.Law.Commutativity.check(
            of: { (a: Int, b: Int) in a - b },
            over: [1, 2]
        )
        #expect(result != nil)
    }

    @Test
    func `distributivity fails for broken ring`() {
        let result = Algebra.Law.Distributivity.left(
            of: Algebra.Law.Test.brokenDistributivityRing,
            over: [1, 2, 3]
        )
        #expect(result != nil)
    }

    @Test
    func `annihilation fails for broken ring`() {
        let result = Algebra.Law.Annihilation.zero(
            of: Algebra.Law.Test.brokenAnnihilationRing,
            over: [1, 2, 3]
        )
        #expect(result != nil)
    }

    @Test
    func `reciprocal fails for broken field`() {
        let result = Algebra.Law.Reciprocal.check(
            of: Algebra.Law.Test.brokenReciprocalField,
            over: [true, false]
        )
        #expect(result != nil)
    }
}
