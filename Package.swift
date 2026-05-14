// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "CalendarView",
    platforms: [
        .iOS(.v18),
    ],
    products: [
        .library(
            name: "CalendarView",
            targets: ["CalendarView"]),
    ],
    dependencies: [
        .package(
            url: "https://github.com/exyte/AnchoredPopup.git",
            from: "1.0.7"
        ),
        .package(
            url: "https://github.com/exyte/PopupView.git",
            from: "4.0.0"
        )
    ],
    targets: [
        .target(
            name: "CalendarView",
            dependencies: [
                .product(name: "AnchoredPopup", package: "AnchoredPopup"),
                .product(name: "PopupView", package: "PopupView")
            ],
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency")
            ]
        ),
    ]
)
