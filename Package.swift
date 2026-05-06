// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "PianoKeyboard",
    platforms: [
        .iOS(.v17),
    ],
    products: [
        .library(
            name: "PianoKeyboard",
            targets: ["PianoKeyboard"]
        )
    ],
    dependencies: [
        // MusicCore is checked out alongside this repo. Path-pinned so
        // editing the shared types doesn't require a tag bump.
        .package(path: "../../../MusicCore"),
    ],
    targets: [
        .target(
            name: "PianoKeyboard",
            dependencies: [
                .product(name: "MusicTheory", package: "MusicCore"),
            ],
            path: "Source"
        ),
        .testTarget(
            name: "PianoKeyboardTests",
            dependencies: [
                "PianoKeyboard"
            ])
    ]
)
