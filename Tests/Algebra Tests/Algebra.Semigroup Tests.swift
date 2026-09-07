import Testing

@testable import Algebra

private struct MoveOnlySemigroupElement: ~Copyable {
    let value: Int
}

private struct NonescapableSemigroupElement: ~Copyable, ~Escapable {}

private typealias NonescapableSemigroup = Algebra.Semigroup<NonescapableSemigroupElement>

private enum Semigroup {}

extension Semigroup {
    @Suite
    struct `Semigroups preserve the supplied associative operation` {
    }
}

extension Semigroup.`Semigroups preserve the supplied associative operation` {
    @Test
    func `init stores combining operation`() {
        let semigroup = Algebra.Semigroup<Int>(combining: { $0 &+ $1 })
        #expect(semigroup.combining(3, 4) == 7)
    }

    @Test
    func `associativity holds for addition`() {
        let semigroup = Algebra.Semigroup<Int>(combining: { $0 &+ $1 })
        let a = 1
        let b = 2
        let c = 3
        let leftAssoc = semigroup.combining(semigroup.combining(a, b), c)
        let rightAssoc = semigroup.combining(a, semigroup.combining(b, c))
        #expect(leftAssoc == rightAssoc)
    }

    @Test
    func `magma projection preserves operation`() {
        let semigroup = Algebra.Semigroup<Int>(combining: { $0 &+ $1 })
        let magma = semigroup.magma
        #expect(magma.combining(3, 4) == semigroup.combining(3, 4))
    }

    @Test
    func `Semigroup combination consumes noncopyable elements`() {
        let semigroup = Algebra.Semigroup<MoveOnlySemigroupElement>(
            combining: { lhs, rhs in .init(value: lhs.value + rhs.value) }
        )
        let lhs = MoveOnlySemigroupElement(value: 3)
        let rhs = MoveOnlySemigroupElement(value: 4)
        let result = semigroup(lhs, rhs)
        #expect(result.value == 7)
    }
}

extension Semigroup.`Semigroups preserve the supplied associative operation` {
    @Test
    func `Semigroup combination concatenates strings in order`() {
        let semigroup = Algebra.Semigroup<String>(combining: { $0 + $1 })
        let result = semigroup.combining(semigroup.combining("a", "b"), "c")
        #expect(result == "abc")
    }
}
