# Algebra

![Development Status](https://img.shields.io/badge/status-active--development-blue.svg)

Witness value types for the algebraic tower — magma, semigroup, monoid, group, ring, field, module, semilattice, lattice — that carry a structure's operations as stored closures, with the type name asserting the mathematical laws.

---

## Quick Start

`Algebra` types are *witnesses*: each one bundles the operations of an algebraic structure (its identity, its binary operation, its inverse) into a value, and the type name records the laws those operations are required to satisfy. Associativity, commutativity, idempotency, and the rest are documented invariants the constructing code must guarantee — they are not re-checked at every call.

A bounded join-semilattice is the algebraic core of a state-based CRDT: any associative, commutative, *idempotent* merge with an identity converges. The witness makes that structure explicit and reusable.

```swift
import Algebra

// A grow-only counter merges by taking the per-replica maximum.
// `max` is associative, commutative, and idempotent — a bounded semilattice with bottom 0.
let merge = Algebra.Semilattice<Int>.maximum(bottom: 0)

let replicaA = 5
let replicaB = 3
merge.combining(replicaA, replicaB)   // 5  (least upper bound)
merge.combining(replicaA, replicaA)   // 5  (idempotent — re-merging is a no-op)

// The merge induces a partial order: a ≤ b iff a ∨ b == b.
merge.leq(3, 5)                        // true
```

Stack two semilattices and you get a bounded lattice, with join, meet, and the order they share:

```swift
import Algebra

// Any Comparable chain is a distributive bounded lattice: join = max, meet = min.
let lattice = Algebra.Lattice<Int>.minMax(bottom: .min, top: .max)

lattice.join(3, 7)   // 7   (∨ = least upper bound)
lattice.meet(3, 7)   // 3   (∧ = greatest lower bound)
lattice.leq(3, 7)    // true
```

The same vocabulary scales up to rings and fields, where convenience accessors (`zero`, `one`, `adding`, `multiplying`, `reciprocal`) read off the underlying monoids and groups. The `Algebra.Law` harnesses verify a witness's invariants over a finite sample of elements, returning an `Algebra.Law.Violation?` that is `nil` when the law holds — pure functions with no traps, ready to drop into a test.

---

## Installation

```swift
dependencies: [
    .package(url: "https://github.com/swift-molecules/swift-algebra.git", branch: "main")
]
```

```swift
.target(
    name: "App",
    dependencies: [
        .product(name: "Algebra", package: "swift-algebra"),
    ]
)
```

Import `Algebra` for the whole tower, or depend on a single rung (e.g. `Algebra Semilattice`) to pull in only what you use.

---

## Architecture

The package is split along the algebraic tower so each rung is an independent product depending only on the rungs below it. The `Algebra` namespace is shared by all of them.

| Product | Target | Purpose |
|---------|--------|---------|
| `Algebra Primitive` | `Sources/Algebra Primitive/` | The empty `Algebra` namespace enum that every structure extends. |
| `Algebra Magma` | `Sources/Algebra Magma/` | `Algebra.Magma` — a set with one binary operation, no laws. |
| `Algebra Semigroup` | `Sources/Algebra Semigroup/` | `Algebra.Semigroup` — associative magma. |
| `Algebra Monoid` | `Sources/Algebra Monoid/` | `Algebra.Monoid` and `Algebra.Monoid.Commutative` — semigroup with identity. |
| `Algebra Semiring` | `Sources/Algebra Semiring/` | `Algebra.Semiring` and its commutative variant — additive and multiplicative monoids with distributivity. |
| `Algebra Semilattice` | `Sources/Algebra Semilattice/` | `Algebra.Semilattice` — idempotent commutative monoid (the CRDT merge). |
| `Algebra Lattice` | `Sources/Algebra Lattice/` | `Algebra.Lattice` — join and meet semilattices with absorption and bounds. |
| `Algebra Group` | `Sources/Algebra Group/` | `Algebra.Group` and `Algebra.Group.Abelian` — monoid with inverses. |
| `Algebra Ring` | `Sources/Algebra Ring/` | `Algebra.Ring` and its commutative variant — additive abelian group with multiplicative monoid. |
| `Algebra Field` | `Sources/Algebra Field/` | `Algebra.Field` and `Algebra.Field.Unit` — ring with a partial reciprocal. |
| `Algebra Module` | `Sources/Algebra Module/` | `Algebra.Module` and `Algebra.VectorSpace` — scalars acting on a vector group. |
| `Algebra Law` | `Sources/Algebra Law/` | `Algebra.Law` verification harnesses (associativity, commutativity, identity, inverse, distributivity, annihilation, reciprocal, action, compatibility) returning `Algebra.Law.Violation?`. |
| `Algebra` | `Sources/Algebra/` | Umbrella re-exporting every rung above. |
| `Algebra Test Support` | `Tests/Support/` | Re-exports the umbrella for test consumers. |

Foundation-free.

---

## Platform Support

| Platform | Status |
|----------|--------|
| macOS 26 | Full support |
| Linux | Full support |
| Windows | Full support |
| iOS / tvOS / watchOS / visionOS | Supported |

---

## Community

<!-- BEGIN: discussion -->
<!-- Discussion thread created at publication. -->
<!-- END: discussion -->

## License

Apache 2.0. See [LICENSE.md](LICENSE.md).
