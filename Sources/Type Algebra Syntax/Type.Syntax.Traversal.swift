import Type_Algebra

extension Type.Syntax {
    public enum Traversal {
        public static func interpret<Output>(
            _ type: Expression,
            value: String,
            parameter: String,
            constant: (Expression, String) throws -> Output,
            transform: (String) throws -> Output,
            collection: (Bool, String, String, Output) throws -> Output,
            product: (Expression, [(String?, Output)], Int) throws -> Output
        ) throws -> Output {
            guard type.algebra.isTraversable else {
                throw Type.Failure(
                    "structural traversal requires known, finite traversable positions"
                )
            }
            let plan = try Type.Mapping.derive(type.algebra, forward: [.init(parameter)])
            func emit(
                _ plan: Type.Mapping,
                _ shape: Expression,
                _ value: String,
                _ depth: Int
            ) throws -> Output {
                switch (plan, shape) {
                case (.identity, _): return try constant(shape, value)
                case (.transform, _): return try transform(value)
                case (.list(let child), .array(let element)):
                    let binding = "element\(depth)"
                    return try collection(
                        false,
                        value,
                        binding,
                        emit(child, element, binding, depth + 1)
                    )
                case (.sum(let children), .optional(let element)):
                    guard children.count == 2 else {
                        throw Type.Failure("invalid optional traversal")
                    }
                    let binding = "element\(depth)"
                    return try collection(
                        true,
                        value,
                        binding,
                        emit(children[1], element, binding, depth + 1)
                    )
                case (.product(let children), .tuple(let coordinates)):
                    guard children.count == coordinates.count else {
                        throw Type.Failure("invalid product traversal")
                    }
                    let parts = try coordinates.enumerated().map { index, coordinate in
                        (
                            coordinate.label,
                            try emit(
                                children[index],
                                coordinate.type,
                                "(\(value)).\(index)",
                                depth + 1
                            )
                        )
                    }
                    return try product(shape, parts, depth)
                default: throw Type.Failure("Swift representation does not match traversal plan")
                }
            }
            return try emit(plan, type, value, 0)
        }
    }
}
