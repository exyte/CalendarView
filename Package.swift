// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "CalendarView",
    platforms: [
        .iOS(.v17),
    ],
    products: [
        .library(
            name: "CalendarView",
            targets: ["CalendarView"]),
    ],
    dependencies: [
        .package(
            url: "https://github.com/exyte/AnchoredPopup.git",
            from: "1.0.6"
        )
    ],
    targets: [
        .target(
            name: "CalendarView",
            dependencies: [.product(name: "AnchoredPopup", package: "AnchoredPopup")],
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency")
            ]
        ),
    ]
)
