// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import CompilerPluginSupport
import PackageDescription

let package = Package(
    name: "Netrofit",
    platforms: [.macOS(.v10_15), .iOS(.v13), .tvOS(.v13), .watchOS(.v6), .macCatalyst(.v13)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "Netrofit",
            targets: ["Netrofit"]
        ),
        .executable(
            name: "NetrofitClient",
            targets: ["NetrofitClient"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-syntax", from: "600.0.1"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        // Macro implementation that performs the source transformation of a macro.
        .macro(
            name: "NetrofitMacros",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
            ]
        ),

        // Library that exposes a macro as part of its API, which is used in client programs.
        .target(name: "Netrofit", dependencies: ["NetrofitMacros"]),

        // A client of the library, which is able to use the macro in its own code.
        .executableTarget(name: "NetrofitClient", dependencies: ["Netrofit"]),

        .testTarget(
            name: "NetrofitTests",
            dependencies: [
                "Netrofit",
            ],
        ),
    ]
)
