public import Type_Algebra
import SwiftSyntax

extension Type.Syntax {
    /// Swift emission for a mapping whose eligibility and variance are decided by Type.Mapping.
    public enum Mapping {
        public static func apply(_ type: Expression, to value: String,
            forward: [String: String], backward: [String: String] = [:], depth: Int = 0) throws -> String {
            let plan = try Type.Mapping.derive(type.algebra,
                forward: Set(forward.keys.map(Type.Variable.init)), backward: Set(backward.keys.map(Type.Variable.init)))
            return try emit(plan, shape: type, value: value, forward: forward, backward: backward, depth: depth)
        }

        private static func emit(_ plan: Type.Mapping, shape: Expression, value: String,
            forward: [String: String], backward: [String: String], depth: Int) throws -> String {
            switch (plan, shape) {
            case (.identity, _): return value
            case let (.transform(variable, direction), _):
                guard let transform = (direction == .forward ? forward : backward)[variable.name] else {
                    throw Type.Failure("missing Swift representation of a mapping")
                }
                return "\(transform)(\(value))"
            case let (.list(child), .array(element)):
                let variable = "element\(depth)"
                return "(\(value)).map { \(variable) in \(try emit(child, shape: element, value: variable, forward: forward, backward: backward, depth: depth + 1)) }"
            case let (.sum(children), .optional(element)):
                guard children.count == 2 else { throw Type.Failure("optional mapping must have two alternatives") }
                let variable = "element\(depth)"
                return "(\(value)).map { \(variable) in \(try emit(children[1], shape: element, value: variable, forward: forward, backward: backward, depth: depth + 1)) }"
            case let (.product(children), .tuple(coordinates)):
                guard children.count == coordinates.count else { throw Type.Failure("tuple mapping arity mismatch") }
                let fields = try coordinates.enumerated().map { index, coordinate in
                    let label = coordinate.label.map { $0 == "_" ? "" : "\($0): " } ?? ""
                    return label + (try emit(children[index], shape: coordinate.type, value: "(\(value)).\(index)", forward: forward, backward: backward, depth: depth + 1))
                }
                return "(\(fields.joined(separator: ", ")))"
            case let (.exponential(domain, codomain), .arrow(inputs, output)):
                guard case .product(let children) = domain, children.count == inputs.count else {
                    throw Type.Failure("function mapping arity mismatch")
                }
                let arguments = inputs.indices.map { "argument\(depth)_\($0)" }
                let mapped = try inputs.enumerated().map { index, input in
                    try emit(children[index], shape: input, value: arguments[index], forward: forward, backward: backward, depth: depth + 1)
                }
                let call = "(\(value))(\(mapped.joined(separator: ", ")))"
                let result = try emit(codomain, shape: output, value: call, forward: forward, backward: backward, depth: depth + 1)
                return "{ \(arguments.isEmpty ? "" : arguments.joined(separator: ", ") + " in ")\(result) }"
            default: throw Type.Failure("Swift representation does not match the derived mapping")
            }
        }
    }
}
