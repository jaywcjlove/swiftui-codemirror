// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CodeMirror",
    platforms: [
        .iOS(.v14),
        .macOS(.v14),
    ],
    products: [
        .library(
            name: "CodeMirror",
            targets: ["CodeMirror"]
        )
    ],
    dependencies: [],
    targets: [
        .target(
            name: "CodeMirror",
            exclude: [
                "html/codemirror.js",
                "html/node_modules",
                "html/package-lock.json",
                "html/package.json",
                "html/rollup.config.mjs",
            ],
            resources: [
                .copy("html/web.bundle")
            ]
        )
    ]
)
