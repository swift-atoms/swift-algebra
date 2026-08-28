import Algebra_Ring

extension Algebra.Field {

    public enum Error: Swift.Error, Sendable {

        case nonInvertible
    }
}
