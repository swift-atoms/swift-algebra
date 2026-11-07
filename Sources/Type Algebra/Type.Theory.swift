extension Type {
    public struct Theory: Equatable, Sendable {
        public let signature: Signature
        public let equations: [Equation]
        public init(signature: Signature, equations: [Equation]) {
            self.signature = signature
            self.equations = equations
        }
    }
}
