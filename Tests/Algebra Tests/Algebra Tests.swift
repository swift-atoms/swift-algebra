import Testing

@testable import Algebra

extension Algebra {
    @Suite
    struct `The Algebra namespace is available to clients` {
    }
}

extension Algebra.`The Algebra namespace is available to clients` {
    @Test
    func `namespace is available`() {
        _ = Algebra.self
    }
}
