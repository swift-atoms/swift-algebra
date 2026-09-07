import Testing

@testable import Algebra

extension Algebra {
    @Suite
    struct `Modules delegate addition and scalar multiplication to their algebra` {
    }
}

extension Algebra.`Modules delegate addition and scalar multiplication to their algebra` {
    static var integerModule: Algebra.Module<Int, Int> {
        .init(
            scalars: .init(
                additive: .init(
                    group: .init(
                        identity: 0,
                        combining: { $0 &+ $1 },
                        inverting: { 0 &- $0 }
                    )
                ),
                multiplicative: .init(
                    identity: 1,
                    combining: { $0 &* $1 }
                )
            ),
            vectors: .init(
                group: .init(
                    identity: 0,
                    combining: { $0 &+ $1 },
                    inverting: { 0 &- $0 }
                )
            ),
            scaling: { $0 &* $1 }
        )
    }

    @Test
    func `operations delegate to their algebraic structures`() {
        let module = Self.integerModule

        #expect(module.zero == 0)
        #expect(module.one == 1)
        #expect(module.adding(2, 3) == 5)
        #expect(module.negating(4) == -4)
        #expect(module.scaling(3, 4) == 12)
    }
}
