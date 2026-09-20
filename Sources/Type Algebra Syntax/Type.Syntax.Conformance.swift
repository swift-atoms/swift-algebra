public import SwiftSyntax

extension Type.Syntax {
    public enum Conformance {
        /// Syntactic evidence only: aliases and inherited protocol refinements require semantic resolution.
        public static func contains(_ name: String, in declaration: some DeclGroupSyntax) -> Bool {
            let inheritance: InheritanceClauseSyntax?
            if let value = declaration.as(StructDeclSyntax.self) { inheritance = value.inheritanceClause }
            else if let value = declaration.as(EnumDeclSyntax.self) { inheritance = value.inheritanceClause }
            else if let value = declaration.as(ProtocolDeclSyntax.self) { inheritance = value.inheritanceClause }
            else { return false }
            return inheritance?.inheritedTypes.contains {
                let spelling = $0.type.trimmedDescription
                return spelling == name || spelling == "Swift." + name || spelling == "Swift::" + name
            } ?? false
        }
    }
}
