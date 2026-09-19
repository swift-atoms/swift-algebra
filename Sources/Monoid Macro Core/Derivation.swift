import Type_Algebra_Syntax
public import SwiftSyntax
import SwiftSyntaxBuilder
public enum Derivation {
    public static func members(of declaration: some DeclGroupSyntax) throws -> [DeclSyntax] {
        guard let structure = declaration.as(StructDeclSyntax.self) else { throw AlgebraDiagnostic("@Monoid derives product monoids on structs; sums need an explicit operation") }
        let properties = StoredProperties(structure, requiresMemberwise: true)
        guard properties.diagnostics.isEmpty else { throw AlgebraDiagnostic(properties.diagnostics.joined(separator: "; ")) }
        guard structure.inheritanceClause?.inheritedTypes.contains(where: { $0.type.trimmedDescription == "~Copyable" }) != true else {
            throw AlgebraDiagnostic("@Monoid uses Copyable Algebra.Monoid witnesses; owned products require an explicit ownership-aware algebra")
        }
        let fields = properties.fields
        let parameters = fields.map { "\($0.name): Algebra::Algebra.Monoid<\($0.type.trimmedDescription)>" }.joined(separator: ", ")
        let identity = fields.map { "\($0.name): \($0.name).identity" }.joined(separator: ", ")
        let combine = fields.map { "\($0.name): \($0.name).combining(lhs.\($0.name), rhs.\($0.name))" }.joined(separator: ", ")
        return [DeclSyntax(stringLiteral: """
            \(RecursiveShape.access(of: structure))static func monoid(\(parameters)) -> Algebra::Algebra.Monoid<Self> {
                .init(identity: Self(\(identity)), combining: { lhs, rhs in Self(\(combine)) })
            }
            """)]
    }
}
