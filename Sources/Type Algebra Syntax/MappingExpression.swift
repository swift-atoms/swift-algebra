import SwiftSyntax

/// The action of a type expression on supplied arrows. This builds one expression,
/// not a macro's members, conformances, or a second representation of a domain type.
public enum MappingExpression {
    public static func apply(_ type: TypeExpression, to value: String,
        forward: [String: String], backward: [String: String] = [:], depth: Int = 0) throws -> String {
        switch type {
        case .constant: return value
        case .parameter(let name):
            guard let transform = forward[name] else {
                throw AlgebraDiagnostic("parameter `\(name)` occurs in the wrong variance position; supply a bidirectional mapping or an explicit implementation")
            }
            return "\(transform)(\(value))"
        case .array(let element), .optional(let element):
            let variable = "element\(depth)"
            return "(\(value)).map { \(variable) in \(try apply(element, to: variable, forward: forward, backward: backward, depth: depth + 1)) }"
        case .tuple(let coordinates):
            let fields = try coordinates.enumerated().map { index, coordinate in
                let label = coordinate.label.map { $0 == "_" ? "" : "\($0): " } ?? ""
                return label + (try apply(coordinate.type, to: "(\(value)).\(index)", forward: forward, backward: backward, depth: depth + 1))
            }
            return "(\(fields.joined(separator: ", ")))"
        case .arrow(let inputs, let output):
            let arguments = inputs.indices.map { "argument\(depth)_\($0)" }
            let mapped = try inputs.enumerated().map { index, input in
                try apply(input, to: arguments[index], forward: backward, backward: forward, depth: depth + 1)
            }
            let call = "(\(value))(\(mapped.joined(separator: ", ")))"
            let result = try apply(output, to: call, forward: forward, backward: backward, depth: depth + 1)
            return "{ \(arguments.isEmpty ? "" : arguments.joined(separator: ", ") + " in ")\(result) }"
        case .unsupported(let syntax, _): throw AlgebraDiagnostic("unsupported mapping of `\(syntax.trimmedDescription)`")
        }
    }
}
