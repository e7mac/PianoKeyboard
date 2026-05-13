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
        .package(url: "https://github.com/e7mac/MusicCore.git", branch: "main"),
    ],
    targets: [
        .target(
            name: "PianoKeyboard",
            dependencies: [
                .product(name: "MusicTheory", package: "MusicCore"),
                .product(name: "AudioEngine", package: "MusicCore"),
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
