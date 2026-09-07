import Testing

@testable import Algebra

private struct MoveOnlyMagmaElement: ~Copyable {
    let value: Int
}

private struct NonescapableMagmaElement: ~Copyable, ~Escapable {}

private typealias NonescapableMagma = Algebra.Magma<NonescapableMagmaElement>

private enum Magma {}

extension Magma {
    @Suite
    struct `Magmas apply the supplied operation to their elements` {
    }
}

extension Magma.`Magmas apply the supplied operation to their elements` {
    @Test
    func `init stores combining operation`() {
        let magma = Algebra.Magma<Int>(combining: { $0 &+ $1 })
        #expect(magma.combining(3, 4) == 7)
    }

    @Test
    func `combining closure is applied correctly`() {
        let magma = Algebra.Magma<String>(combining: { $0 + $1 })
        #expect(magma.combining("hello", " world") == "hello world")
    }

    @Test
    func `Magma combination applies the supplied multiplication`() {
        let magma = Algebra.Magma<Int>(combining: { $0 &* $1 })
        #expect(magma.combining(3, 4) == 12)
    }

    @Test
    func `Magma combination consumes noncopyable elements`() {
        let magma = Algebra.Magma<MoveOnlyMagmaElement>(
            combining: { lhs, rhs in .init(value: lhs.value + rhs.value) }
        )
        let lhs = MoveOnlyMagmaElement(value: 3)
        let rhs = MoveOnlyMagmaElement(value: 4)
        let result = magma(lhs, rhs)
        #expect(result.value == 7)
    }
}

extension Magma.`Magmas apply the supplied operation to their elements` {
    @Test
    func `Magma combination supports a nonassociative operation`() {
        let magma = Algebra.Magma<Int>(combining: { $0 &- $1 })
        let leftAssoc = magma.combining(magma.combining(10, 3), 2)
        let rightAssoc = magma.combining(10, magma.combining(3, 2))
        #expect(leftAssoc != rightAssoc)
    }
}
