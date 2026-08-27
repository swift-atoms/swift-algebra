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
            name: "Algebra Standard Library Integration",
            targets: ["Algebra Standard Library Integration"]
        ),
        .library(
            name: "Algebra Apple Foundation Integration",
            targets: ["Algebra Apple Foundation Integration"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Algebra",
            dependencies: []
        ),
        .target(
            name: "Algebra Standard Library Integration",
            dependencies: ["Algebra"]
        ),
        .target(
            name: "Algebra Apple Foundation Integration",
            dependencies: [
                "Algebra",
                "Algebra Standard Library Integration",
            ]
        ),
        .testTarget(
            name: "Algebra Tests",
            dependencies: [
                "Algebra",
                "Algebra Standard Library Integration",
            ],
            path: "Tests/Algebra Tests"
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
