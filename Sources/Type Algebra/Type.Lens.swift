extension Type {
    /// A structural coordinate lens, optionally changing the selected coordinate's type.
    /// The unchanged-type specialization satisfies the ordinary get/put lens laws.
    public struct Lens: Equatable, Sendable {
        public let get: Morphism
        public let put: Morphism

        public static func coordinate(_ label: String, in record: Record, replacingWith replacementType: Expression? = nil) throws -> Self {
            guard let index = record.fields.firstIndex(where: { $0.name == label }) else { throw Failure("unknown lens coordinate") }
            let types = record.fields.map(\.type)
            let domain = [record.expression, replacementType ?? types[index]]
            let old = try Morphism.projection(domain, at: 0)
            let replacement = try Morphism.projection(domain, at: 1)
            let fields = try types.indices.map { field in
                field == index ? replacement : try old.followed(by: .projection(types, at: field))
            }
            return Self(get: try .projection(types, at: index), put: try .pairing(from: .product(domain), fields))
        }
    }
}
