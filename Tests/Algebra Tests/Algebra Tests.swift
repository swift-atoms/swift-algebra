import Testing

@testable import Algebra

enum `Algebra Tests` {}

extension `Algebra Tests` {
    @Suite
    struct `The Algebra namespace is available to clients` {
    }
}

extension `Algebra Tests`.`The Algebra namespace is available to clients` {
    @Test
    func `namespace is available`() {
        _ = Algebra.self
    }
}
