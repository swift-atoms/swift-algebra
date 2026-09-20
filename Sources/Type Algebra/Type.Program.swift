extension Type {
    public enum Program {
        /// A fixed applicative batch: all operation choices are made before their results arrive.
        /// A free applicative ranges over all finite batches of this form; no commutativity is assumed.
        public struct Batch: Equatable, Sendable {
            public let operations: [Operation]
            public let result: Expression
            public init(_ names: [String], in signature: Signature, returning result: Expression) throws {
                operations = try names.map { name in
                    guard let operation = signature.operations.first(where: { $0.name == name }) else {
                        throw Failure("unknown operation in applicative batch")
                    }
                    return operation
                }
                self.result = result
            }
            public var inputs: Expression { .product(operations.map(\.input)) }
            public var outputs: Expression { .product(operations.map(\.output)) }
            public var expression: Expression {
                .product([inputs, .exponential(domain: outputs, codomain: result)])
            }
        }

        public static func monadic(_ signature: Signature, returning result: Expression,
            variable: Variable) throws -> Recursion {
            guard signature.operations.allSatisfy({ !$0.input.variables.contains(variable) && !$0.output.variables.contains(variable) }) else {
                throw Failure("program recursion must not capture an operation's sort variable")
            }
            return try .free(layer: signature.continuation(.variable(variable)), variable: variable, returning: result)
        }

        /// Coinductive interaction-tree shape with return, visible operations and silent steps.
        /// A Swift interpreter must separately choose a productive/lazy representation.
        public static func interaction(_ signature: Signature, returning result: Expression,
            variable: Variable) throws -> Recursion {
            let finite = try monadic(signature, returning: result, variable: variable)
            return try Recursion(.greatest, variable: variable, body: .sum([finite.body, .variable(variable)]))
        }
    }
}
