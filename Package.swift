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

        .library(name: "Algebra Foundation Integration", targets: ["Algebra Foundation Integration"]),
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
            name: "Algebra Foundation Integration",
            dependencies: [
                .target(name: "Algebra"),
            ],
            path: "Sources/Algebra Foundation Integration"
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
                .target(name: "Algebra Foundation Integration"),
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
