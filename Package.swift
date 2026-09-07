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
        .library(name: "Algebra", targets: ["Algebra"]),
        .library(name: "Algebra Standard Library Integration", targets: ["Algebra Standard Library Integration"]),
        .library(name: "Algebra Foundation Library Integration", targets: ["Algebra Foundation Library Integration"]),
        .library(name: "Algebra Test Support", targets: ["Algebra Test Support"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Algebra",
            dependencies: [
            ],
            path: "Sources/Algebra"
        ),
        .target(
            name: "Algebra Standard Library Integration",
            dependencies: [
                .target(name: "Algebra"),
            ],
            path: "Sources/Algebra Standard Library Integration"
        ),
        .target(
            name: "Algebra Foundation Library Integration",
            dependencies: [
                .target(name: "Algebra"),
                .target(name: "Algebra Standard Library Integration"),
            ],
            path: "Sources/Algebra Foundation Library Integration"
        ),
        .target(
            name: "Algebra Test Support",
            dependencies: [
                .target(name: "Algebra"),
            ],
            path: "Tests/Support"
        ),
        .testTarget(
            name: "Algebra Tests",
            dependencies: [
                .target(name: "Algebra"),
                .target(name: "Algebra Test Support"),
                .target(name: "Algebra Standard Library Integration"),
                .target(name: "Algebra Foundation Library Integration"),
            ],
            path: "Tests/Algebra Tests"
        ),
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets {
    target.swiftSettings = [
        .strictMemorySafety(),
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
        .enableExperimentalFeature("Lifetimes"),
        .enableUpcomingFeature("InferIsolatedConformances"),
    ]
}
