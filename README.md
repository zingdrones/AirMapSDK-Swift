# AirMapSDK-Swift

[![CI Status](http://img.shields.io/travis/AirMap/AirMapSDK.svg?style=flat)](https://travis-ci.org/AirMap/AirMapSDK) [![Version](https://img.shields.io/cocoapods/v/AirMapSDK.svg?style=flat)](http://cocoapods.org/pods/AirMapSDK) [![License](https://img.shields.io/cocoapods/l/AirMapSDK.svg?style=flat)](http://cocoapods.org/pods/AirMapSDK) [![Platform](https://img.shields.io/cocoapods/p/AirMapSDK.svg?style=flat)](http://cocoapods.org/pods/AirMapSDK)

Create Flights, Send Telemetry Data, Get Realtime Traffic Alerts.

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements
iOS 8.0+, macOS 10.10+
Swift 2.2
Xcode 7.3+

## Installation

### CocoaPods

The AirMap SDK is a CocoaPod written in Swift. CocoaPods is a dependency manager for Cocoa projects. You can install it with the following command:

`$ gem install cocoapods`

To integrate the AirMap SDK into your Xcode project, navigate to the directory that contains your project and create a new **Podfile** with `pod init` or open an existing one, then add `pod ‘AirMapSDK’` to the main loop. If you are using the Swift SDK, make sure to add the line `use_frameworks!`.

```ruby
use_frameworks!
target 'Your Project's Target Name' do
	pod 'AirMapSDK'
end
```

Then, run the following command to install the dependency:

`$ pod install`

For Objective-C projects, set the **Embedded Content Contains Swift Code** flag in your project to **Yes** (found under **Build Options** in the **Build Settings** tab).

Requires CocoaPods 0.39.0+

### Carthage

AirMapSDK is available through [Carthage](http://https://github.com/Carthage/Carthage). Add the following line to your Cartfile:

```
github "AirMap/AirMapSDK-Swift"
```

Then run `carthage update`

## Initializing The SDK

An API key & auth token are required to use the AirMap SDK. Sign up via the [AirMap developer portal](https://www.airmap.com/makers/) for access.

```swift
import AirMap

// After Authentication with AirMap, configure AirMapSDK

func userDidAuthenticateWithAirMap() {
	AirMap.configure(apiKey: "<#API Key#>", authToken: "<#Auth Token#>")
}
```

## Flights

#### Create Flight

```swift
var flight = AirMapFlight()
flight.startsAt = NSDate()
flight.endsAt = NSDate().dateByAddingTimeInterval(360)
flight.coordinate.latitude = 34.0168106
flight.coordinate.longitude = -118.4972862
flight.altitude = 100
flight.radius = 1000
flight.isPublic = true

AirMap.createFlight(flight) { flight, error in
	if let error = error {
		print(error)
	} else {
		print(flight)
	}
}
```

#### Close Flight

```swift
AirMap.closeFlight(flight) { flight, error in
	if let error = error {
		print(error)
	} else {
		print(flight)
	}
}
```


#### Update Flight

```swift
AirMap.updateFlight(flight) { flight, error in
	if let error = error {
		print(error)
	} else {
		print(flight)
	}
}
```

#### List Flights

```swift
AirMap.getUserFlights() { flights, error in
	if let error = error {
		print(error)
	} else {
		print(flight)
	}
}
```

#### Delete Flight

```swift
AirMap.deleteFlight(flight) { error in
	if let error = error {
		print(error)
	}
}
```


## Telemetry

#### Send Telemetry Data

```swift
AirMap.sendTelemetryData(
	flight: flight,
	coordinate: coordinate,
	altitude: 380,
	groundSpeed: 0,
	trueHeading: 271,
	baro: 29.92
)
```

## Traffic Alerts

In order to observer AirMap Traffic alerts in your application, your observer needs to conform to the `AirMapTrafficObserver` protocol.

```swift

extension MyViewController: AirMapTrafficObserver {
            
    func airMapTrafficServiceDidAdd(traffic: [AirMapTraffic]) {
        
	    for t in traffic {
	        switch t.trafficType {
	        case .SituationalAwareness:
	            <# add traffic to map #>
	        case .Alert:
	            <# add traffic to map #>
	            <# show alert #>
	        }
	    }
    }

    func airMapTrafficServiceDidUpdate(traffic: [AirMapTraffic]) {
        <# handle updates to existing traffic #>
        <# present alert for .Alert traffic #>
    }

    func airMapTrafficServiceDidRemove(traffic: [AirMapTraffic]) {
        <# handle removal of old traffic #>
    }

		// Optional    
    func airMapTrafficServiceDidConnect {
        <# update UI to reflect connection state #>
    }

		// Optional    
    func airMapTrafficServiceDidDisconnect {
        <# update UI to reflect connection state #>
    }
}
```

## Flight Status

#### Point Status

```swift
let coordinate = CLLocationCoordinate2D(latitude: 34.0168106, longitude: -118.4972862)

AirMap.checkCoordinate(coordinate, radius: 100) { status, error in
	if let error = error {
		print(error)
	} else {
		print(status)
	}
}
```


#### Path Status

```swift
let geometry = [
	CLLocationCoordinate2D(latitude: 41.00, longitude: -109.50)
	CLLocationCoordinate2D(latitude: 40.99, longitude: -102.06)
	CLLocationCoordinate2D(latitude: 36.99, longitude: -102.03)
	CLLocationCoordinate2D(latitude: 36.99, longitude: -109.04)
]

AirMapClient.checkFlightPath(geometry, width: 1) { status, error in
	if let error = error {
		print(error)
	} else {
		print(status)
	}
}
```

#### Polygon Status

```swift
let polygon = [
	CLLocationCoordinate2D(latitude: 41.00, longitude: -109.50)
	CLLocationCoordinate2D(latitude: 41.00, longitude: -109.05)
	CLLocationCoordinate2D(latitude: 40.99, longitude: -102.06)
	CLLocationCoordinate2D(latitude: 36.99, longitude: -102.03)
	CLLocationCoordinate2D(latitude: 41.00, longitude: -109.05)
]

AirMapClient.checkPolygon(geometry) { status, error in
	if let error = error {
		print(error)
	} else {
		print(status)
	}
}
```

## License

TBD. See LICENSE for details.
