extension Type {
    /// A frontend-independent composition of operation arrows and opaque child capabilities.
    /// No macro name, Swift declaration, or child API spelling is part of this description.
    public struct Interface: Equatable, Sendable {
        public let signature: Signature
        public let children: Record
        public init(signature: Signature, children: Record) throws {
            guard Set(signature.operations.map(\.name)).isDisjoint(with: children.fields.map(\.name)) else {
                throw Failure("operations and child coordinates must have distinct identities")
            }
            self.signature = signature; self.children = children
        }
        public var implementation: Record {
            // Uniqueness follows from both validated inputs and the disjointness check above.
            get throws {
                try Record(signature.operations.map { .init($0.name, $0.implementation) } + children.fields)
            }
        }
        /// Children supply their own request sort explicitly; their implementation type is not a request.
        public func requests(children requests: Record) throws -> Expression {
            try requestRecord(children: requests).alternatives
        }
        public func requestRecord(children requests: Record) throws -> Record {
            guard requests.fields.map(\.name) == children.fields.map(\.name) else {
                throw Failure("child requests must match the child coordinates in order")
            }
            return try Record(signature.operations.map { .init($0.name, $0.input) } + requests.fields)
        }
    }

    /// Equations are obligations, not evidence. A model must establish them separately.
    public struct Equation: Equatable, Sendable {
        public let lhs: Morphism
        public let rhs: Morphism
        public init(_ lhs: Morphism, _ rhs: Morphism) throws {
            guard lhs.domain == rhs.domain, lhs.codomain == rhs.codomain else {
                throw Failure("an equation requires parallel maps")
            }
            self.lhs = lhs; self.rhs = rhs
        }
    }
    public struct Theory: Equatable, Sendable {
        public let signature: Signature
        public let equations: [Equation]
        public init(signature: Signature, equations: [Equation]) {
            self.signature = signature; self.equations = equations
        }
    }
}
