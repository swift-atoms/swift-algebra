public import Type_Algebra

extension Type.Syntax {
    /// Swift representation of a stored coordinate. Mathematical identity and selection live in Type.Record.
    public struct Record {
        public struct Field {
            public let name: String
            public let type: String
            public let label: String
            public let binding: String
            public let argument: String
            public let initial: String?
            public let mutable: Bool
            public let access: String?
            public init(_ name: String, type: String, label: String? = nil, binding: String? = nil, argument: String? = nil,
                initial: String? = nil, mutable: Bool = true, access: String? = nil) {
                self.name = name; self.type = type; self.label = label ?? name; self.binding = binding ?? name
                self.argument = argument ?? type; self.initial = initial; self.mutable = mutable; self.access = access
            }
        }
        public let fields: [Field]
        public let algebra: Type.Record
        public init(_ fields: [Field]) throws {
            self.fields = fields
            algebra = try Type.Record(fields.map { .init($0.name, .atom(.init($0.type, scope: ["Swift"]))) })
        }
        public init(_ algebra: Type.Record, representation: (Type.Record.Field) throws -> Field) rethrows {
            self.algebra = algebra
            self.fields = try algebra.fields.map(representation)
        }
        public func selecting(_ labels: [String]) throws -> Self {
            let selection = try algebra.selecting(labels)
            return Self(algebra: selection.record, fields: selection.indices.map { fields[$0] })
        }
        private init(algebra: Type.Record, fields: [Field]) {
            self.algebra = algebra; self.fields = fields
        }
        public var tupleType: String {
            fields.isEmpty ? "Void" : fields.count == 1 ? fields[0].type : "(" + fields.map(\.type).joined(separator: ", ") + ")"
        }
        public func unpacking(_ value: String) -> Interpretation.Product {
            .product(fields.indices.map { .value(fields.count == 1 ? value : "\(value).\($0)") })
        }
        public func declarations(access: String) -> [String] {
            fields.map { "\($0.access ?? access)\($0.mutable ? "var" : "let") \($0.name): \($0.type)" + ($0.initial.map { " = \($0)" } ?? "") }
        }
        public var parameters: String {
            fields.map { field in
                let name = field.label == field.binding ? field.binding : "\(field.label) \(field.binding)"
                return "\(name): \(field.argument)" + (field.initial.map { " = \($0)" } ?? "")
            }.joined(separator: ", ")
        }
        public func initializer(access: String, parameters selected: [String]? = nil) throws -> String {
            let record = try selected.map(selecting) ?? self
            let assignments = record.fields.map { "self.\($0.name) = \($0.binding)" }.joined(separator: "\n")
            return "\(access)init(\(record.parameters)) {\n\(assignments)\n}"
        }
    }
}
