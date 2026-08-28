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
                "Algebra"
            ]
        ),
        .target(
            name: "Algebra Semigroup",
            dependencies: [
                "Algebra Magma"
            ]
        ),
        .target(
            name: "Algebra Monoid",
            dependencies: [
                "Algebra Semigroup"
            ]
        ),
        .target(
            name: "Algebra Semiring",
            dependencies: [
                "Algebra Monoid"
            ]
        ),
        .target(
            name: "Algebra Semilattice",
            dependencies: [
                "Algebra Monoid",
                "Algebra Semigroup",
            ]
        ),
        .target(
            name: "Algebra Lattice",
            dependencies: [
                "Algebra Semilattice"
            ]
        ),
        .target(
            name: "Algebra Group",
            dependencies: [
                "Algebra Monoid"
            ]
        ),
        .target(
            name: "Algebra Ring",
            dependencies: [
                "Algebra Group",
                "Algebra Semiring",
            ]
        ),
        .target(
            name: "Algebra Field",
            dependencies: [
                "Algebra Ring"
            ]
        ),
        .target(
            name: "Algebra Module",
            dependencies: [
                "Algebra Field"
            ]
        ),

        .target(
            name: "Algebra Law",
            dependencies: [
                "Algebra Field",
                "Algebra Module",
            ]
        ),

        .testTarget(
            name: "Algebra Tests",
            dependencies: [
                "Algebra",
                "Algebra Magma",
                "Algebra Semigroup",
                "Algebra Monoid",
                "Algebra Semiring",
                "Algebra Semilattice",
                "Algebra Lattice",
                "Algebra Group",
                "Algebra Ring",
                "Algebra Field",
                "Algebra Module",
                "Algebra Law",
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
