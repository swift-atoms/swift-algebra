// swift-tools-version: 6.4

import CompilerPluginSupport
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
        .library(name: "Monoid Macro", targets: ["Monoid Macro"]),
        .library(name: "Type Algebra", targets: ["Type Algebra"]),
        .library(name: "Type Algebra Syntax", targets: ["Type Algebra Syntax"]),
        .library(name: "Algebra", targets: ["Algebra"]),

        .library(name: "Algebra Foundation Integration", targets: ["Algebra Foundation Integration"]),
        .library(name: "Algebra Test Support", targets: ["Algebra Test Support"]),
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-custom-dump", from: "1.0.0"),
        .package(url: "https://github.com/swiftlang/swift-syntax.git", "603.0.2"..<"604.0.0"),
    ],
    targets: [
        .target(name: "Type Algebra", dependencies: []),
        .testTarget(name: "Type Algebra Tests", dependencies: ["Type Algebra", .product(name: "CustomDump", package: "swift-custom-dump")]),
        .testTarget(name: "Monoid Macro Tests", dependencies: [
            "Monoid Macro",
            "Algebra Test Support",
        ]),
        .testTarget(name: "Type Algebra Syntax Tests", dependencies: [
            "Type Algebra Syntax",
            .product(name: "CustomDump", package: "swift-custom-dump"),
            .product(name: "SwiftParser", package: "swift-syntax"),
            .product(name: "SwiftSyntax", package: "swift-syntax"),
        ]),
        .target(name: "Monoid Macro", dependencies: [
            "Monoid Macro Plugin",
            "Algebra",
        ]),
        .macro(name: "Monoid Macro Plugin", dependencies: [
            "Monoid Macro Core",
            .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
            .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
            .product(name: "SwiftSyntax", package: "swift-syntax"),
        ]),
        .target(name: "Monoid Macro Core", dependencies: [
            .product(name: "SwiftSyntax", package: "swift-syntax"),
            .product(name: "SwiftSyntaxBuilder", package: "swift-syntax"),
            "Type Algebra Syntax",
        ]),
        .target(name: "Type Algebra Syntax", dependencies: [
            "Type Algebra",
            .product(name: "SwiftSyntaxBuilder", package: "swift-syntax"),
            .product(name: "SwiftSyntax", package: "swift-syntax"),
        ]),
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

// Generated API consumers must treat visibility diagnostics as hard errors.
for target in package.targets where target.type == .test || target.name.hasSuffix("Consumer Fixtures") {
    target.swiftSettings = (target.swiftSettings ?? []) + [.treatAllWarnings(as: .error)]
}
