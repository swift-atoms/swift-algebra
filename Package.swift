// swift-tools-version: 6.4

import PackageDescription

let package = Package(
    name: "swift-algebra",
    platforms: [
        .macOS(.v27),
        .iOS(.v27),
        .tvOS(.v27),
        .watchOS(.v27),
        .visionOS(.v27),
    ],
    products: [
        .library(
            name: "Algebra",
            targets: ["Algebra"]
        ),
        .library(
            name: "Algebra Magma",
            targets: ["Algebra Magma"]
        ),
        .library(
            name: "Algebra Semigroup",
            targets: ["Algebra Semigroup"]
        ),
        .library(
            name: "Algebra Monoid",
            targets: ["Algebra Monoid"]
        ),
        .library(
            name: "Algebra Semiring",
            targets: ["Algebra Semiring"]
        ),
        .library(
            name: "Algebra Semilattice",
            targets: ["Algebra Semilattice"]
        ),
        .library(
            name: "Algebra Lattice",
            targets: ["Algebra Lattice"]
        ),
        .library(
            name: "Algebra Group",
            targets: ["Algebra Group"]
        ),
        .library(
            name: "Algebra Ring",
            targets: ["Algebra Ring"]
        ),
        .library(
            name: "Algebra Field",
            targets: ["Algebra Field"]
        ),
        .library(
            name: "Algebra Module",
            targets: ["Algebra Module"]
        ),
        .library(
            name: "Algebra Law",
            targets: ["Algebra Law"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Algebra",
            dependencies: []
        ),
        .target(
            name: "Algebra Magma",
            dependencies: [
                .target(name: "Algebra")
            ]
        ),
        .target(
            name: "Algebra Semigroup",
            dependencies: [
                .target(name: "Algebra Magma")
            ]
        ),
        .target(
            name: "Algebra Monoid",
            dependencies: [
                .target(name: "Algebra Semigroup")
            ]
        ),
        .target(
            name: "Algebra Semiring",
            dependencies: [
                .target(name: "Algebra Monoid")
            ]
        ),
        .target(
            name: "Algebra Semilattice",
            dependencies: [
                .target(name: "Algebra Monoid"),
                .target(name: "Algebra Semigroup"),
            ]
        ),
        .target(
            name: "Algebra Lattice",
            dependencies: [
                .target(name: "Algebra Semilattice")
            ]
        ),
        .target(
            name: "Algebra Group",
            dependencies: [
                .target(name: "Algebra Monoid")
            ]
        ),
        .target(
            name: "Algebra Ring",
            dependencies: [
                .target(name: "Algebra Group"),
                .target(name: "Algebra Semiring"),
            ]
        ),
        .target(
            name: "Algebra Field",
            dependencies: [
                .target(name: "Algebra Ring")
            ]
        ),
        .target(
            name: "Algebra Module",
            dependencies: [
                .target(name: "Algebra Field")
            ]
        ),
        .target(
            name: "Algebra Law",
            dependencies: [
                .target(name: "Algebra Field"),
                .target(name: "Algebra Module"),
            ]
        ),
        .testTarget(
            name: "Algebra Tests",
            dependencies: [
                .target(name: "Algebra")
            ]
        ),
        .testTarget(
            name: "Algebra Magma Tests",
            dependencies: [
                .target(name: "Algebra Magma")
            ]
        ),
        .testTarget(
            name: "Algebra Semigroup Tests",
            dependencies: [
                .target(name: "Algebra Semigroup")
            ]
        ),
        .testTarget(
            name: "Algebra Monoid Tests",
            dependencies: [
                .target(name: "Algebra Monoid")
            ]
        ),
        .testTarget(
            name: "Algebra Semiring Tests",
            dependencies: [
                .target(name: "Algebra Semiring")
            ]
        ),
        .testTarget(
            name: "Algebra Semilattice Tests",
            dependencies: [
                .target(name: "Algebra Semilattice")
            ]
        ),
        .testTarget(
            name: "Algebra Lattice Tests",
            dependencies: [
                .target(name: "Algebra Lattice")
            ]
        ),
        .testTarget(
            name: "Algebra Group Tests",
            dependencies: [
                .target(name: "Algebra Group")
            ]
        ),
        .testTarget(
            name: "Algebra Ring Tests",
            dependencies: [
                .target(name: "Algebra Ring")
            ]
        ),
        .testTarget(
            name: "Algebra Field Tests",
            dependencies: [
                .target(name: "Algebra Field")
            ]
        ),
        .testTarget(
            name: "Algebra Module Tests",
            dependencies: [
                .target(name: "Algebra Module")
            ]
        ),
        .testTarget(
            name: "Algebra Law Tests",
            dependencies: [
                .target(name: "Algebra Law")
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets where ![.system, .binary, .plugin, .macro].contains(target.type) {
    let ecosystem: [SwiftSetting] = [
        .strictMemorySafety(),
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
        .enableExperimentalFeature("Lifetimes"),
        .enableUpcomingFeature("InferIsolatedConformances"),
    ]

    let package: [SwiftSetting] = []

    target.swiftSettings = (target.swiftSettings ?? []) + ecosystem + package
}
