import Testing

@testable import Algebra

extension Algebra {
    @Suite
    struct Test {
    }
}

extension Algebra.Test {
    @Test
    func `namespace is available`() {
        _ = Algebra.self
    }
}
