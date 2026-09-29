public import Algebra

extension Algebra.Law {
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
