// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "TravelPlannerApp",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "TravelPlannerApp",
            targets: ["TravelPlannerApp"]),
    ],
    dependencies: [
        .package(url: "https://github.com/firebase/firebase-ios-sdk", from: "10.18.0"),
        .package(url: "https://github.com/google/GoogleSignIn-iOS", from: "7.0.0")
    ],
    targets: [
        .target(
            name: "TravelPlannerApp",
            dependencies: [
                .product(name: "FirebaseAuth", package: "firebase-ios-sdk"),
                .product(name: "FirebaseFirestore", package: "firebase-ios-sdk"),
                .product(name: "GoogleSignIn", package: "GoogleSignIn-iOS")
            ]
        )
    ]
)
