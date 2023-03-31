// swift-tools-version: 5.7

import PackageDescription

let package = Package(name: "GroutUI",
                      platforms: [.macOS(.v13), .iOS(.v16), .watchOS(.v9)],
                      products: [
                          .library(name: "GroutUI",
                                   targets: ["GroutUI"]),
                      ],
                      dependencies: [
                          .package(url: "https://github.com/openalloc/SwiftCompactor", from: "1.3.0"),
                          .package(url: "https://github.com/apple/swift-collections.git", from: "1.0.4"),
                          .package(url: "https://github.com/gym-routine-tracker/GroutLib.git", from: "1.1.0"),
                          .package(url: "https://github.com/open-trackers/TrackerUI.git", from: "1.0.0"),
                          .package(url: "https://github.com/openalloc/SwiftTextFieldPreset.git", from: "1.0.0"),
                      ],
                      targets: [
                          .target(name: "GroutUI",
                                  dependencies: [
                                      .product(name: "GroutLib", package: "GroutLib"),
                                      .product(name: "TrackerUI", package: "TrackerUI"),
                                      .product(name: "Compactor", package: "SwiftCompactor"),
                                      .product(name: "Collections", package: "swift-collections"),
                                      .product(name: "TextFieldPreset", package: "SwiftTextFieldPreset"),
                                  ],
                                  path: "Sources"),
                          .testTarget(name: "GroutUITests",
                                      dependencies: ["GroutUI"],
                                      path: "Tests"),
                      ])
