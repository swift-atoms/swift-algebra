public import SwiftSyntax
public import Type_Algebra


extension Type.Syntax.Expression {
    public struct Coordinate {
        public let label: String?
        public let type: Type.Syntax.Expression
        public init(label: String?, type: Type.Syntax.Expression) {
            self.label = label
            self.type = type
        }
    }
}
