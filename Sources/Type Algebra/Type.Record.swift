extension Type {
    public struct Record: Equatable, Sendable {
        public let fields: [Field]
        public init(_ fields: [Field]) throws {
            guard Set(fields.map(\.name)).count == fields.count else {
                throw Failure("record labels must be unique")
            }
            self.fields = fields
        }
    }
}

extension Type.Record {
    public struct Field: Equatable, Sendable {
        public let name: String
        public let type: Expression
        public init(_ name: String, _ type: Expression) {
            self.name = name
            self.type = type
        }
    }

    public var expression: Expression { .product(fields.map(\.type)) }

    public var alternatives: Expression { .sum(fields.map(\.type)) }

    public var partial: Expression { .product(fields.map { .optional($0.type) }) }

    public var optional: Expression { .optional(expression) }

    public var endomorphism: Expression {
        .exponential(domain: expression, codomain: expression)
    }

    public struct Selection: Equatable, Sendable {
        public let record: Record
        public let indices: [Int]
        public let projection: Morphism
    }

    public func selecting(_ labels: [String]) throws -> Selection {
        guard Set(labels).count == labels.count else {
            throw Failure("a field selection cannot repeat labels")
        }
        let indices = try labels.map { label in
            guard let index = fields.firstIndex(where: { $0.name == label }) else {
                throw Failure("unknown coordinate `\(label)`")
            }
            return index
        }
        let maps = try indices.map { try Morphism.projection(fields.map(\.type), at: $0) }
        return Selection(
            record: try Record(indices.map { fields[$0] }),
            indices: indices,
            projection: try .pairing(from: expression, maps)
        )
    }

    public func excluding(_ labels: [String]) throws -> Selection {
        _ = try selecting(labels)
        return try selecting(fields.map(\.name).filter { !labels.contains($0) })
    }

    public func selections(limit: Int = 4096) throws -> [Selection] {
        guard limit > 0 else { throw Failure("selection limit must be positive") }
        var labels: [[String]] = [[]]
        for field in fields {
            guard labels.count <= limit / 2 else {
                throw Failure("the subproduct family exceeds the requested limit")
            }
            labels += labels.map { $0 + [field.name] }
        }
        return try labels.map(selecting)
    }
}
