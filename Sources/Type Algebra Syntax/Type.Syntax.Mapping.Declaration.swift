public import SwiftSyntax
import SwiftSyntaxBuilder

extension Type.Syntax.Mapping {
    public struct Parameter {
        public let target: String
        public let forward: String?
        public let backward: String?
        public init(_ target: String, forward: String? = nil, backward: String? = nil) {
            self.target = target; self.forward = forward; self.backward = backward
        }
    }

    /// A Swift method interpreting the core mapping action. Semantic packages choose the
    /// method and parameter directions; product/coproduct reconstruction is shared here.
    public static func members(of declaration: some DeclGroupSyntax, method: String,
        parameters mappings: [Parameter]) throws -> [DeclSyntax] {
        let parameters: [String]
        let name: String
        let fields: [Type.Syntax.Expression]
        let structure: Type.Syntax.Product?
        let cases: [EnumCaseElementSyntax]
        if let value = declaration.as(StructDeclSyntax.self) {
            let shape = try Type.Syntax.Product(value, arity: mappings.count)
            structure = shape; parameters = shape.parameters; name = value.name.text
            fields = shape.fields; cases = []
        } else if let value = declaration.as(EnumDeclSyntax.self) {
            guard let generics = value.genericParameterClause, generics.parameters.count == mappings.count,
                generics.parameters.allSatisfy({ $0.inheritedType == nil }), value.genericWhereClause == nil else {
                throw Type.Failure("requires \(mappings.count) unconstrained generic parameter(s)")
            }
            parameters = generics.parameters.map(\.name.text); name = value.name.text; structure = nil
            cases = Type.Syntax.Recursion.elements(of: value)
            fields = cases.flatMap { Type.Syntax.Recursion.parameters(of: $0) }.map {
                Type.Syntax.Expression($0.type, parameters: Set(parameters))
            }
        } else { throw Type.Failure("mapping requires a struct or enum") }
        let escaping = mappings.contains { $0.backward != nil } || fields.contains { $0.containsArrow } ? "@escaping " : ""
        let forward = Dictionary(uniqueKeysWithValues: zip(parameters, mappings).compactMap { name, map in map.forward.map { (name, $0) } })
        let backward = Dictionary(uniqueKeysWithValues: zip(parameters, mappings).compactMap { name, map in map.backward.map { (name, $0) } })
        let arguments = zip(parameters, mappings).flatMap { name, map in
            [map.forward.map { "_ \($0): \(escaping)(\(name)) -> \(map.target)" },
             map.backward.map { "_ \($0): \(escaping)(\(map.target)) -> \(name)" }].compactMap { $0 }
        }.joined(separator: ", ")
        let generics = mappings.map(\.target).joined(separator: ", ")
        let target = "\(name)<\(generics)>"
        let body: String
        if let structure {
            let values = try structure.properties.fields.enumerated().map { index, field in
                field.name + ": " + (try apply(fields[index], to: "self.\(field.name)", forward: forward, backward: backward))
            }
            body = "\(target)(\(values.joined(separator: ", ")))"
        } else {
            let branches = try cases.map { item in
                let payloads = Type.Syntax.Recursion.parameters(of: item)
                if payloads.isEmpty { return "case .\(item.name.text): return .\(item.name.text)" }
                let values = try payloads.enumerated().map { index, payload in
                    (Type.Syntax.Recursion.label(of: payload).map { "\($0): " } ?? "")
                        + (try apply(Type.Syntax.Expression(payload.type, parameters: Set(parameters)),
                            to: "value\(index)", forward: forward, backward: backward))
                }
                return "case let .\(item.name.text)(\(payloads.indices.map { "value\($0)" }.joined(separator: ", "))): return .\(item.name.text)(\(values.joined(separator: ", ")))"
            }
            body = "switch self { \(branches.joined(separator: "\n")) }"
        }
        return [DeclSyntax(stringLiteral: """
            \(Type.Syntax.Recursion.access(of: declaration))func \(method)<\(generics)>(\(arguments)) -> \(target) {
                \(body)
            }
            """)]
    }
}
