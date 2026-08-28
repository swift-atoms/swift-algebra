import Testing

@testable import Algebra

@Suite
struct `Algebra Tests` {
    @Test
    func `namespace is available`() {
        _ = Algebra.self
    }
}
