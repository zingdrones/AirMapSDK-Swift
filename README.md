![AirMap: The Airspace Platform for Developers](Resources/Core/AirMap.png)
![Swift 2.3](https://img.shields.io/badge/Swift-3.0-lightgray.svg) [![Version](https://img.shields.io/cocoapods/v/AirMapSDK.svg?style=flat)](http://cocoapods.org/pods/AirMapSDK) [![License](https://img.shields.io/cocoapods/l/AirMapSDK.svg?style=flat)](http://cocoapods.org/pods/AirMapSDK) [![Platform](https://img.shields.io/cocoapods/p/AirMapSDK.svg?style=flat)](http://cocoapods.org/pods/AirMapSDK)

Create Flights, Send Telemetry Data, Get Realtime Traffic Alerts.

## Requirements

### Environment
* iOS 9.0+, 
* macOS 10.10+, 
* Swift 3.0 or 3.1
* Xcode 8.2+

### Sign up for an [AirMap Developer Account.](https://dashboard.airmap.io/developer/)

 [https://dashboard.airmap.io/developer](https://dashboard.airmap.io/developer)
  
### Read Getting Started Guide
[https://developers.airmap.com/v2.0/docs/ios-getting-started/](https://developers.airmap.com/v2.0/docs/ios-getting-started/)

## Installation

### CocoaPods

Requires CocoaPods 1.2.0+

The AirMap SDK is a CocoaPod written in Swift. CocoaPods is a dependency manager for Cocoa projects. If you don't have CocoaPods, You can install it with the following command:

`$ sudo gem install cocoapods`


### Example Project

***You must have Xcode 8.2+ to run the example.***

To run the example project, run `pod try AirMapSDK`.  This should install the SDK and launch Xcode.

### Integrating into your project

To integrate the AirMap SDK into your Xcode project, navigate to the directory that contains your project and create a new **Podfile** with `pod init` or open an existing one, then add `pod 'AirMapSDK'` to the main target. Make sure to add the line `use_frameworks!`.

```ruby
target 'MyApp' do
  use_frameworks!
	pod 'AirMapSDK'
end
```

Then, run the following command to install the dependencies:

`$ pod install`

Going forward, open the `MyProject.xcworkspace` file instead of the `MyProject.xcodeproj` file.

Make sure you import the framework before using the SDK.

```swift
import AirMap
```

## Examples

### Getting Airspace Status

```swift
// Create a coordinate or source one from the device's GPS
let myCoord = CLLocationCoordinate2D(latitude: 34.02, longitude: -118.50)

// Check the coordinate with a buffer of 100 Meters
AirMap.checkCoordinate(coordinate: myCoord, buffer: 100) { (result: Result<AirMapStatus>) in
	
	// The result is either an error or a value
	switch result {
	
	case .error(let error):
		// handle the error
		print(error)

	case .value(let status):
		
		// print the overall airspace status color (i.e. red, yellow, green)
		print("Airspace Status Color:", status.advisoryColor)

		// print the number of airspace advisories returned
		print("Number of Advisories:", status.advisories.count)
		
		// print out details for each advisory
		for advisory in status.advisories {
			print("\n")
			print("Name:     ", advisory.name)
			print("Type:     ", advisory.type.title)
			print("Color:    ", advisory.color)
			print("Distance: ", advisory.distance, "meters")
		}
	}
}
```

## License 

See [LICENSE](https://raw.githubusercontent.com/airmap/AirMapSDK-Swift/master/LICENSE) for details
