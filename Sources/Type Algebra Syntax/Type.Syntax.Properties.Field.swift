public import SwiftSyntax
public import Type_Algebra


extension Type.Syntax.Properties {
    public struct Field {
        public let declaration: VariableDeclSyntax
        public let binding: PatternBindingSyntax
        public let name: String
        public let type: TypeSyntax
    }
}
