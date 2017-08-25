// swift-tools-version:3.1

import PackageDescription

var package = Package(name: "AirMap")

let core = Target(name: "Core")
package.targets.append(core)

let rx = Target(name: "Rx")
package.targets.append(rx)

