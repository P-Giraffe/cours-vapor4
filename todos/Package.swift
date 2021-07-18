// swift-tools-version:5.2
import PackageDescription

let package = Package(
    name: "todos",
    platforms: [
       .macOS(.v10_15)
    ],
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "4.48.2"),
        .package(url: "https://github.com/vapor/fluent.git", from: "4.3.1"),
        .package(url: "https://github.com/vapor/fluent-sqlite-driver.git", from: "4.1.0"),
        .package(url: "https://github.com/vapor/fluent-mysql-driver.git", from: "4.0.0")
    ],
    targets: [
        .target(name: "App", dependencies: [
            .product(name: "Fluent", package: "fluent"),
            .product(name: "FluentSQLiteDriver", package: "fluent-sqlite-driver"),
            .product(name: "FluentMySQLDriver", package: "fluent-mysql-driver"),
            .product(name: "Vapor", package: "vapor")
        ]),
        .target(name: "Run", dependencies: ["App"]),
        .testTarget(name: "AppTests", dependencies: [
            .target(name: "App"),
            .product(name: "XCTVapor", package: "vapor"),
        ])
    ]
)
