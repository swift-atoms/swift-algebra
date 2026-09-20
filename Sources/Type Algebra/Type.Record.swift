extension Type {
    public struct Record: Equatable, Sendable {
        public struct Field: Equatable, Sendable {
            public let name: String
            public let type: Expression
            public init(_ name: String, _ type: Expression) { self.name = name; self.type = type }
        }
        public let fields: [Field]
        public init(_ fields: [Field]) throws {
            guard Set(fields.map(\.name)).count == fields.count else { throw Failure("record labels must be unique") }
            self.fields = fields
        }
        public var expression: Expression { .product(fields.map(\.type)) }
        public var alternatives: Expression { .sum(fields.map(\.type)) }
        public var partial: Expression { .product(fields.map { .optional($0.type) }) }
        public var optional: Expression { .optional(expression) }
        public var endomorphism: Expression { .exponential(domain: expression, codomain: expression) }

        public struct Selection: Equatable, Sendable {
            public let record: Record
            public let indices: [Int]
            public let projection: Morphism
        }
        public func selecting(_ labels: [String]) throws -> Selection {
            guard Set(labels).count == labels.count else { throw Failure("a field selection cannot repeat labels") }
            let indices = try labels.map { label in
                guard let index = fields.firstIndex(where: { $0.name == label }) else { throw Failure("unknown coordinate `\(label)`") }
                return index
            }
            let maps = try indices.map { try Morphism.projection(fields.map(\.type), at: $0) }
            return Selection(record: try Record(indices.map { fields[$0] }), indices: indices,
                projection: try .pairing(from: expression, maps))
        }
        public func excluding(_ labels: [String]) throws -> Selection {
            _ = try selecting(labels)
            return try selecting(fields.map(\.name).filter { !labels.contains($0) })
        }

        /// Derive all labelled selections only on explicit request, with an allocation bound.
        public func selections(limit: Int = 4096) throws -> [Selection] {
            guard limit > 0 else { throw Failure("selection limit must be positive") }
            var labels: [[String]] = [[]]
            for field in fields {
                guard labels.count <= limit / 2 else { throw Failure("the subproduct family exceeds the requested limit") }
                labels += labels.map { $0 + [field.name] }
            }
            return try labels.map(selecting)
        }
    }

    /// A checked permutation supplies inverse maps by construction, without identifying their types.
    public struct Isomorphism: Equatable, Sendable {
        public let forward: Morphism
        public let backward: Morphism
        public static func distribution(_ factor: Expression, over alternatives: [Expression]) -> Self {
            Self(forward: .distribution(factor, over: alternatives), backward: .factorization(factor, from: alternatives))
        }
        public static func productUnit(_ value: Expression) throws -> Self {
            Self(forward: try .projection([.unit, value], at: 1),
                backward: try .pairing(from: value, [.terminal(from: value), .identity(value)]))
        }
        public static func sumZero(_ value: Expression) throws -> Self {
            Self(forward: try .elimination(to: value, [.initial(to: value), .identity(value)]),
                backward: try .injection([.zero, value], at: 1))
        }
        public static func permutation(of record: Record, order: [String]) throws -> Self {
            guard order.count == record.fields.count else { throw Failure("a permutation must include every coordinate") }
            let selected = try record.selecting(order)
            let inverse = try selected.record.selecting(record.fields.map(\.name))
            return Self(forward: selected.projection, backward: inverse.projection)
        }
    }
}
