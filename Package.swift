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
            type: .static,
            targets: ["GraphQLite"])
    ],
    targets: [
        .target(
            name: "GraphQLite",
            dependencies: [],
            path: "./ios-sdk",
            sources: ["Sources"]
        )
    ]
)
