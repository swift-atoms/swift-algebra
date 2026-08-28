import Testing

@testable import Algebra_Magma

@Suite
struct `Algebra.Magma Tests` {
    @Suite struct Unit {}
    @Suite struct EdgeCase {}
}

extension `Algebra.Magma Tests`.Unit {
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
    func `combining with multiplication`() {
        let magma = Algebra.Magma<Int>(combining: { $0 &* $1 })
        #expect(magma.combining(3, 4) == 12)
    }
}

extension `Algebra.Magma Tests`.EdgeCase {
    @Test
    func `combining with non-associative operation`() {

        let magma = Algebra.Magma<Int>(combining: { $0 &- $1 })
        let leftAssoc = magma.combining(magma.combining(10, 3), 2)
        let rightAssoc = magma.combining(10, magma.combining(3, 2))
        #expect(leftAssoc != rightAssoc)
    }
}
