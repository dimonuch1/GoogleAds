// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "GoogleAds",
    platforms: [.iOS(.v15)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "GoogleAds",
            targets: ["GoogleAds"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/googleads/swift-package-manager-google-mobile-ads.git",
                 from: "10.10.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "GoogleAds",
            dependencies: [
                .product(name: "GoogleMobileAds",
                         package: "swift-package-manager-google-mobile-ads")
            ]),
        .testTarget(
            name: "GoogleAdsTests",
            dependencies: ["GoogleAds"]),
    ]
)
