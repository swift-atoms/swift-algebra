public import Type_Algebra
public import SwiftSyntax

/// The source-written stored instance properties, before accessor expansion.
/// Every consumer shares this representation and selects its construction policy.
extension Type.Syntax {
    public struct Properties {
        public struct Field {
            public let declaration: VariableDeclSyntax
            public let binding: PatternBindingSyntax
            public let name: String
            public let type: TypeSyntax
            public var isMutable: Bool { declaration.bindingSpecifier.tokenKind == .keyword(.var) }
            public var defaultValue: ExprSyntax? { binding.initializer?.value }
        }

        public let declaration: StructDeclSyntax
        public let fields: [Field]
        public let diagnostics: [String]
        public let hasCustomInitializer: Bool

        public init(_ declaration: StructDeclSyntax, requiresMemberwise: Bool = false) {
            self.declaration = declaration
            var fields: [Field] = []
            var reasons: [String] = []
            hasCustomInitializer = declaration.memberBlock.members.contains { $0.decl.is(InitializerDeclSyntax.self) }
            if requiresMemberwise && hasCustomInitializer {
                reasons.append("requires the synthesized memberwise initializer; structs with custom initializers must define their derivation explicitly")
            }
            for member in declaration.memberBlock.members {
                guard let variable = member.decl.as(VariableDeclSyntax.self),
                    !variable.modifiers.contains(where: { ["static", "class"].contains($0.name.text) }) else { continue }
                for binding in variable.bindings {
                    if let accessors = binding.accessorBlock {
                        if accessors.tokens(viewMode: .sourceAccurate).contains(where: { ["willSet", "didSet"].contains($0.text) }) {
                            reasons.append("does not support observed stored properties")
                        }
                        continue
                    }
                    guard let identifier = binding.pattern.as(IdentifierPatternSyntax.self) else {
                        reasons.append("requires each stored instance property to use a simple identifier pattern")
                        continue
                    }
                    let name = identifier.identifier.text
                    guard let type = binding.typeAnnotation?.type else {
                        reasons.append("requires stored property `\(name)` to have an explicit type annotation")
                        continue
                    }
                    if variable.modifiers.contains(where: { $0.name.text == "lazy" }) {
                        reasons.append("does not support lazy stored property `\(name)`")
                        continue
                    }
                    if !variable.attributes.isEmpty {
                        reasons.append("does not support attributes or property wrappers on stored property `\(name)`")
                        continue
                    }
                    if requiresMemberwise && variable.bindingSpecifier.tokenKind == .keyword(.let) && binding.initializer != nil {
                        reasons.append("does not support initialized constant `\(name)` because it is not a memberwise initializer parameter")
                        continue
                    }
                    fields.append(Field(declaration: variable, binding: binding, name: name, type: type))
                }
            }
            self.fields = fields
            diagnostics = reasons
        }
    }

}
