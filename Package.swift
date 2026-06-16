// swift-tools-version:6.0
import PackageDescription

let package = Package(
    name: "PianoKeyboard",
    // tools 6.0 is required for `.iOS(.v18)`. `swiftLanguageModes: [.v5]`
    // (set below, after targets) keeps the source compiling in Swift 5 mode —
    // it predates strict concurrency; only the manifest API needs newer tools.
    platforms: [
        .iOS(.v18),
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
    ],
    swiftLanguageModes: [.v5]
)
