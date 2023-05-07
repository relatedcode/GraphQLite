// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "GraphQLite",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "GraphQLite",
            targets: ["GraphQLite"]
            ),
    ],
    targets: [
        .target(
            name: "GraphQLite",
            dependencies: ["GraphQLiteFramework"],
            path: "ios-sdk/Source"
        ),
        .binaryTarget(name: "GraphQLiteFramework",
                      path: "ios-sdk/GraphQLite.xcframework"
        )
    ]
)
