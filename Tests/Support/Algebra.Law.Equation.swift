public import Algebra

extension Algebra.Law {
    /// An executable equation over supplied samples, not a proof over an infinite domain.
    public enum Equation {
        public static func check<Input, Observation: Equatable>(
            _ name: String, over samples: [Input],
            lhs: (Input) -> Observation, rhs: (Input) -> Observation
        ) -> Algebra.Law.Violation<Observation>? {
            for sample in samples {
                let left = lhs(sample), right = rhs(sample)
                if left != right { return .init(law: name, elements: [], lhs: left, rhs: right) }
            }
            return nil
        }
    }
}
