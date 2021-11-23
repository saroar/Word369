// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Word369SPM",
    platforms: [.iOS(.v14),],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(name: "Word369SPM", targets: ["Word369SPM"]),
        .library(name: "AppFeature", targets: ["AppFeature"]),
        .library(name: "ComposableUserNotifications", targets: ["ComposableUserNotifications"]),
    ],
    dependencies: [
      .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "0.28.1"),
      .package(name: "SnapshotTesting", url: "https://github.com/pointfreeco/swift-snapshot-testing.git", from: "1.9.0"),
      .package(url: "https://github.com/pointfreeco/xctest-dynamic-overlay", from: "0.2.0")
    ],
    targets: [
        .target(
            name: "Word369SPM",
            dependencies: []),
        .testTarget(
            name: "Word369SPMTests",
            dependencies: ["Word369SPM"]),

        .target(
            name: "AppFeature",
            dependencies: [
              .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ]
        ),
        .target(
          name: "ComposableUserNotifications",
          dependencies: [
            .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            .product(name: "XCTestDynamicOverlay", package: "xctest-dynamic-overlay"),
          ]
        )
    ]
)
