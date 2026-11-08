extension Type {
    public struct Recursion: Equatable, Sendable {
        public enum Kind: Equatable, Sendable { case least, greatest }
        public let kind: Kind
        public let variable: Variable
        public let body: Expression
        public init(_ kind: Kind, variable: Variable, body: Expression) throws {
            guard body.isStrictlyPositive(in: variable) else {
                throw Failure(
                    "recursive carrier requires a strictly positive, known action in its bound variable"
                )
            }
            self.kind = kind
            self.variable = variable
            self.body = body
        }
        public static func free(
            layer: Expression,
            variable: Variable,
            returning result: Expression
        ) throws -> Self {
            guard !result.variables.contains(variable) else {
                throw Failure("free carrier would capture the result variable")
            }
            return try Self(.least, variable: variable, body: .sum([result, layer]))
        }
        public static func cofree(
            layer: Expression,
            variable: Variable,
            observing result: Expression
        ) throws -> Self {
            guard !result.variables.contains(variable) else {
                throw Failure("cofree carrier would capture the observation variable")
            }
            return try Self(.greatest, variable: variable, body: .product([result, layer]))
        }
    }
}
