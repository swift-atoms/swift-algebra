public import Type_Algebra
public import SwiftSyntax

/// Common, explicit eligibility for reconstructing an unconstrained generic value.
extension Type.Syntax {
    public struct Product {
        public let declaration: StructDeclSyntax
        public let properties: Type.Syntax.Properties
        public let parameters: [String]
        public let fields: [Type.Syntax.Expression]
        public let access: String

        public init(_ declaration: StructDeclSyntax, arity: Int, reconstructing: Bool = true) throws {
            self.declaration = declaration
            properties = Type.Syntax.Properties(declaration, requiresMemberwise: reconstructing)
            if !properties.diagnostics.isEmpty { throw Type.Failure(properties.diagnostics.joined(separator: "; ")) }
            guard let clause = declaration.genericParameterClause, clause.parameters.count == arity,
                clause.parameters.allSatisfy({ $0.inheritedType == nil }), declaration.genericWhereClause == nil else {
                throw Type.Failure("requires \(arity) unconstrained type parameter(s)")
            }
            let names = clause.parameters.map(\.name.text)
            parameters = names
            fields = properties.fields.map { Type.Syntax.Expression($0.type, parameters: Set(names)) }
            if let reason = fields.compactMap(\.diagnostic).first { throw Type.Failure(reason) }
            access = Type.Syntax.Recursion.access(of: declaration)
        }
    }

}
