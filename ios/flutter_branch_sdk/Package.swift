// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "flutter_branch_sdk",
    platforms: [
        .iOS("12.0")
    ],
    products: [
        .library(name: "flutter-branch-sdk", targets: ["flutter_branch_sdk"])
    ],
    dependencies: [
     .package(url: "https://github.com/BranchMetrics/ios-branch-sdk-spm", "3.10.0"..."3.11.0")
    ],
    targets: [
        .target(
            name: "flutter_branch_sdk",
            dependencies: [
            .product(name: "BranchSDK", package: "ios-branch-sdk-spm"),
            ],
            linkerSettings: [
                .linkedFramework("CoreServices"),
                .linkedFramework("SystemConfiguration"),
                .linkedFramework("WebKit", .when(platforms: [.iOS])),
                .linkedFramework("CoreSpotlight", .when(platforms: [.iOS])),
                .linkedFramework("AdServices", .when(platforms: [.iOS]))
            ]
        )
    ]
)
