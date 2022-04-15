// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Word300iOSSPM",
    platforms: [.iOS(.v14),],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(name: "AppFeature", targets: ["AppFeature"]),
        .library(name: "WordFeature", targets: ["WordFeature"]),
        .library(name: "SharedModels", targets: ["SharedModels"]),
        .library(name: "WordClient", targets: ["WordClient"]),
        .library(name: "DayWordCardsFeature", targets: ["DayWordCardsFeature"]),
        .library(name: "DayWordCardFeature", targets: ["DayWordCardFeature"]),
        .library(name: "SettingsFeature", targets: ["SettingsFeature"]),
        .library(name: "UserDefaultsClient", targets: ["UserDefaultsClient"]),
        .library(name: "ComposableUserNotifications", targets: ["ComposableUserNotifications"]),
    ],

    dependencies: [
      .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "0.28.1"),
      .package(name: "SnapshotTesting", url: "https://github.com/pointfreeco/swift-snapshot-testing.git", from: "1.9.0"),
      .package(url: "https://github.com/pointfreeco/xctest-dynamic-overlay", from: "0.2.0"),
      .package(url: "https://github.com/AddaMeSPB/HTTPRequestKit.git", from: "3.0.0")
    ],

    targets: [

        .target(
            name: "AppFeature",
            dependencies: [
              .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
              "ComposableUserNotifications", "WordFeature", "HTTPRequestKit", "WordClient",
              "SharedModels", "UserDefaultsClient"
            ]
        ),

        .target(
            name: "WordFeature",
            dependencies: [
              .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
              "ComposableUserNotifications", "SharedModels", "UserDefaultsClient",
              "HTTPRequestKit", "WordClient", "DayWordCardsFeature", "SettingsFeature"
            ]
        ),

        .target(
            name: "DayWordCardsFeature",
            dependencies: [
              .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
              "SharedModels", "DayWordCardFeature"
            ]
        ),
        
        .target(
          name: "DayWordCardFeature",
          dependencies: [
            .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            "SharedModels"
          ]
        ),
        
        .target(
          name: "SettingsFeature",
          dependencies: [
            .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            "SharedModels", "ComposableUserNotifications", "UserDefaultsClient"
          ]
        ),

        .target(name: "SharedModels"),

        .target(
          name: "WordClient",
          dependencies: [
            .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            "SharedModels", "HTTPRequestKit"
          ]
        ),

        .target(
          name: "ComposableUserNotifications",
          dependencies: [
            .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            .product(name: "XCTestDynamicOverlay", package: "xctest-dynamic-overlay"),
          ]
        ),

        .target(
          name: "UserDefaultsClient",
          dependencies: [
            .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
          ]
        )

    ]
)
