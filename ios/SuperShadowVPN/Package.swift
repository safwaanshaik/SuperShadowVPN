// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "SuperShadowVPN",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "SuperShadowVPN", targets: ["SuperShadowVPN"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-crypto.git", from: "3.0.0")
    ],
    targets: [
        .target(
            name: "SuperShadowVPN",
            dependencies: [
                .product(name: "Crypto", package: "swift-crypto")
            ]
        )
    ]
)