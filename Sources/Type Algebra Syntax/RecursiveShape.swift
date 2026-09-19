public import SwiftSyntax

public enum RecursiveShape {
    public static func access(of declaration: some DeclGroupSyntax) -> String {
        declaration.modifiers.contains { $0.name.tokenKind == .keyword(.public) }
            ? "public "
            : declaration.modifiers.contains { $0.name.text == "package" } ? "package " : ""
    }

    public static func elements(
        of declaration: EnumDeclSyntax
    ) -> [EnumCaseElementSyntax] {
        declaration.memberBlock.members
            .compactMap { $0.decl.as(EnumCaseDeclSyntax.self) }
            .flatMap(\.elements)
    }

    public static func parameters(
        of element: EnumCaseElementSyntax
    ) -> [EnumCaseParameterSyntax] {
        Array(element.parameterClause?.parameters ?? [])
    }

    public static func pattern(
        of parameters: [EnumCaseParameterSyntax]
    ) -> String {
        parameters.enumerated().map { index, parameter in
            guard let label = label(of: parameter) else { return "value\(index)" }
            return "\(label): value\(index)"
        }.joined(separator: ", ")
    }

    public static func arguments(
        of parameters: [EnumCaseParameterSyntax]
    ) -> String {
        parameters.enumerated().map { index, parameter in
            guard let label = label(of: parameter) else { return "value\(index)" }
            return "\(label): value\(index)"
        }.joined(separator: ", ")
    }

    public static func label(
        of parameter: EnumCaseParameterSyntax
    ) -> String? {
        guard let label = parameter.firstName, label.text != "_" else { return nil }
        return label.trimmedDescription
    }

}

extension RecursiveShape {
    /// Direct, regular recursive positions only. Aliases and nonuniform recursion need explicit derivation.
    public static func isRecursive(_ type: TypeSyntax, in declaration: EnumDeclSyntax) -> Bool {
        let text = type.trimmedDescription
        let parameters = declaration.genericParameterClause?.parameters.map(\.name.text) ?? []
        let applied = declaration.name.text + (parameters.isEmpty ? "" : "<" + parameters.joined(separator: ",") + ">")
        return text == "Self" || text.filter { !$0.isWhitespace } == applied
    }

    public static func validate(_ declaration: EnumDeclSyntax) throws {
        guard declaration.genericParameterClause?.parameters.allSatisfy({ $0.inheritedType == nil }) ?? true,
            declaration.genericWhereClause == nil else {
            throw AlgebraDiagnostic("recursive derivation requires unconstrained regular type parameters")
        }
        for item in elements(of: declaration) {
            for parameter in parameters(of: item) {
                let text = parameter.type.trimmedDescription
                let mentionsSelf = parameter.type.tokens(viewMode: .sourceAccurate).contains {
                    $0.text == "Self" || $0.text == declaration.name.text
                }
                if mentionsSelf && !isRecursive(parameter.type, in: declaration) {
                    throw AlgebraDiagnostic("recursive occurrences must be direct regular payloads of Self, not `\(text)`; nested, nonuniform, and mutually recursive forms require an explicit derivation")
                }
            }
        }
    }
}

extension RecursiveShape {
    /// Reject visible cycles through more than one nominal enum. An imported alias cannot be resolved by SwiftSyntax.
    public static func validateNamespace(_ declaration: some DeclGroupSyntax) throws {
        let declarations = declaration.memberBlock.members.compactMap { $0.decl.as(EnumDeclSyntax.self) }
        let names = Set(declarations.map(\.name.text))
        var graph: [String: Set<String>] = [:]
        for enumeration in declarations {
            graph[enumeration.name.text] = Set(elements(of: enumeration).flatMap { parameters(of: $0) }.flatMap {
                TypeExpression.references(in: $0.type, parameters: names)
            }).subtracting([enumeration.name.text])
        }
        func reaches(_ current: String, target: String, visited: Set<String>) -> Bool {
            if current == target { return true }
            guard !visited.contains(current) else { return false }
            return graph[current, default: []].contains { reaches($0, target: target, visited: visited.union([current])) }
        }
        for name in names {
            if graph[name, default: []].contains(where: { reaches($0, target: name, visited: []) }) {
                throw AlgebraDiagnostic("mutually recursive enums require an explicit multi-sorted fixed-point representation")
            }
        }
    }
}
