extension Type {
    /// The ordinary, nondependent type constructors in the zoo. Every operation supplies its extra sorts.
    public enum Construction {
        public static func predicate(on value: Expression) -> Expression {
            .exponential(domain: value, codomain: .sum([.unit, .unit]))
        }
        public static func reader(environment: Expression, value: Expression) -> Expression {
            .exponential(domain: environment, codomain: value)
        }
        public static func state(_ state: Expression, value: Expression) -> Expression {
            .exponential(domain: state, codomain: .product([value, state]))
        }
        public static func writer(output: Expression, value: Expression) -> Expression { .product([value, output]) }
        public static func exception(failure: Expression, value: Expression) -> Expression { .sum([failure, value]) }
        public static func continuation(answer: Expression, value: Expression) -> Expression {
            .exponential(domain: .exponential(domain: value, codomain: answer), codomain: answer)
        }
        /// State is returned even when the operation fails.
        public static func retaining(state: Expression, failure: Expression, value: Expression) -> Expression {
            .exponential(domain: state, codomain: .product([.sum([failure, value]), state]))
        }
        /// Failure exposes no successor state. This shape alone does not promise external rollback.
        public static func discarding(state: Expression, failure: Expression, value: Expression) -> Expression {
            .exponential(domain: state, codomain: .sum([failure, .product([value, state])]))
        }
    }

    /// Explicit data for the constructions that require predicates or relations.
    /// Neither a predicate name nor a relation name is a proof of laws.
    public struct Refinement: Equatable, Sendable {
        public let base: Expression
        public let predicate: Atom
        public init(_ base: Expression, satisfying predicate: Atom) { self.base = base; self.predicate = predicate }
    }
    public struct Quotient: Equatable, Sendable {
        public let base: Expression
        public let relation: Atom
        public init(_ base: Expression, by relation: Atom) { self.base = base; self.relation = relation }
    }

    /// Finite dependent sums/products: retain the index to its corresponding fiber.
    public struct Family: Equatable, Sendable {
        public let fibers: Record
        public init(_ fibers: Record) { self.fibers = fibers }
        public var sum: Expression { fibers.alternatives }
        public var product: Expression { fibers.expression }
        public func fiber(at index: String) throws -> Expression {
            guard let field = fibers.fields.first(where: { $0.name == index }) else { throw Failure("unknown family index") }
            return field.type
        }
    }
}

extension Type.Record {
    public func eliminator(returning result: Type.Expression) -> Type.Expression {
        .product(fields.map { .exponential(domain: $0.type, codomain: result) })
    }
    public var replacement: Type.Expression { alternatives }
    public var transformations: Type.Expression {
        .sum(fields.map { .exponential(domain: $0.type, codomain: $0.type) })
    }
    public var indices: Type.Expression { .sum(fields.map { _ in .unit }) }
    public func context(at label: String) throws -> Selection { try excluding([label]) }
}
