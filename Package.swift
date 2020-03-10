// swift-tools-version:5.1
import PackageDescription

let package = Package(
    name: "ErrorHandler",
    platforms: [
        .iOS(.v10),
        .macOS(.v10_12),
        .watchOS(.v3),
        .tvOS(.v10)
    ],
    products: [
        .library(
            name: "ErrorHandler",
            targets: ["ErrorHandler"]),
    ],
    dependencies: [
         .package(url: "https://github.com/Alamofire/Alamofire.git", .upToNextMajor(from: "5.0.0"))
    ],
    targets: [
        .target(name: "ErrorHandler", dependencies: ["Alamofire"], path: "./ErrorHandler"),
        .testTarget(name: "ErrorHandlerTests", dependencies: ["ErrorHandler"], path: "./Example/Tests")
    ],
    swiftLanguageVersions: [.v4_2, .v5]
)
