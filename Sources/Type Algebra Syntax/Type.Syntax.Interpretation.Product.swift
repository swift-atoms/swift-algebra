public import Type_Algebra

extension Type.Syntax.Interpretation {
    /// Symbolic interpretation of cartesian maps. Leaves must be stable bindings or projections,
    /// not effectful expressions: pairing can duplicate them and terminal can discard them.
    public indirect enum Product {
        case value(String)
        case product([Self])

        public var expression: String {
            switch self {
            case .value(let value): return value
            case .product(let fields):
                return fields.count == 1 ? fields[0].expression : "(" + fields.map(\.expression).joined(separator: ", ") + ")"
            }
        }

        public func applying(_ map: Type.Morphism) throws -> Self {
            switch map.term {
            case .identity: return self
            case .composition(let first, let second): return try applying(first).applying(second)
            case .projection(let index):
                guard case .product(let fields) = self, case .product(let factors) = map.domain,
                    fields.count == factors.count, fields.indices.contains(index) else {
                    throw Type.Failure("product representation does not match projection")
                }
                return fields[index]
            case .pairing(let maps): return .product(try maps.map { try applying($0) })
            case .terminal: return .product([])
            default: throw Type.Failure("this interpretation requires a cartesian map")
            }
        }
    }
}

extension Type.Syntax.Record {
    public func projecting(_ value: String) -> Type.Syntax.Interpretation.Product {
        .product(fields.map { .value("\(value).\($0.name)") })
    }

    public func constructing(_ name: String, from value: Type.Syntax.Interpretation.Product) throws -> String {
        guard case .product(let components) = value, components.count == fields.count else {
            throw Type.Failure("record construction requires one value per field")
        }
        return name + "(" + zip(fields, components).map { field, component in
            (field.label == "_" ? "" : "\(field.label): ") + component.expression
        }.joined(separator: ", ") + ")"
    }
}
