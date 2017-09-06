import PackageDescription

let package = Package(
    name: "ErrorHandler",
    dependencies: [
        .Package(url: "https://github.com/Alamofire/Alamofire.git", versions: Version(4, 0, 0)..<Version(5, 0, 0))
    ],
    exclude: ["Example"]
)
