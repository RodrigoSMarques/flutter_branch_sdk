// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
/*
import Foundation


enum ConfigurationError: Error {
  case fileNotFound(String)
  case parsingError(String)
  case invalidFormat(String)
}

let branchDirectory = String(URL(string: #file)!.deletingLastPathComponent().absoluteString.dropLast())

func loadPubspecVersions() throws -> String {
  let pubspecPath = NSString.path(withComponents: [branchDirectory,"..","..","pubspec.yaml"])
  do {
    let yamlString = try String(contentsOfFile: pubspecPath, encoding: .utf8)
    let lines = yamlString.split(separator: "\\\\r\\\\n")

    guard let packageVersionLine = lines.first(where: { $0.starts(with: "version:") }) else {
        throw ConfigurationError.invalidFormat("No package version line found in pubspec.yaml: \(lines.count)")
    }
    var packageVersion = packageVersionLine.split(separator: ":")[1]
      .trimmingCharacters(in: .whitespaces)
      .replacingOccurrences(of: "+", with: "-")
    packageVersion = packageVersion.replacingOccurrences(of: "^", with: "")
    return packageVersion
  } catch {
    throw ConfigurationError.fileNotFound("Error loading or parsing pubspec.yaml \(pubspecPath) :\n Error: \(error)")
  }
}

let library_version: String

do {
  library_version = try loadPubspecVersions()
} catch {
  fatalError("Failed to load configuration: \(error)")
}
*/

let package = Package(
    name: "flutter_branch_sdk",
    platforms: [
        .iOS("12.0")
    ],
    products: [
        .library(name: "flutter-branch-sdk", targets: ["flutter_branch_sdk"])
    ],
    dependencies: [
     .package(url: "https://github.com/BranchMetrics/ios-branch-sdk-spm", "3.7.0"..."3.8.0")
    ],
    targets: [
        .target(
            name: "flutter_branch_sdk",
            dependencies: [
            .product(name: "BranchSDK", package: "ios-branch-sdk-spm"),
            ],
            //cSettings: [
            //        .define("LIBRARY_VERSION", to: "\"\(library_version)\""),
            //],
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
