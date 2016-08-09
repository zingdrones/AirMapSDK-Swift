# AirMapSDK-Swift

[![CI Status](http://img.shields.io/travis/AirMap/AirMapSDK.svg?style=flat)](https://travis-ci.org/AirMap/AirMapSDK) [![Version](https://img.shields.io/cocoapods/v/AirMapSDK.svg?style=flat)](http://cocoapods.org/pods/AirMapSDK) [![License](https://img.shields.io/cocoapods/l/AirMapSDK.svg?style=flat)](http://cocoapods.org/pods/AirMapSDK) [![Platform](https://img.shields.io/cocoapods/p/AirMapSDK.svg?style=flat)](http://cocoapods.org/pods/AirMapSDK)

Create Flights, Send Telemetry Data, Get Realtime Traffic Alerts.

## Requirements
iOS 8.0+, macOS 10.10+
Swift 2.2
Xcode 7.3+

## Installation

### CocoaPods

Requires CocoaPods 1.0.0+

The AirMap SDK is a CocoaPod written in Swift. CocoaPods is a dependency manager for Cocoa projects. If you don't have CocoaPods, You can install it with the following command:

`$ sudo gem install cocoapods `


### Example Project

***You must have Xcode 7.3 to run the example.***

To run the example project, run `pod try AirMapSDK`.  This should install the SDK and launch Xcode.

### Integration into Your project

To integrate the AirMap SDK into your Xcode project, navigate to the directory that contains your project and create a new **Podfile** with `pod init` or open an existing one, then add `pod ‘AirMapSDK’` to the main target. If you are using the Swift SDK, make sure to add the line `use_frameworks!`.

```ruby
use_frameworks!
target 'Your Project's Target Name' do
	pod 'AirMapSDK'
end
```

Then, run the following command to install the dependency:

`$ pod install`

For Objective-C projects, set the **Embedded Content Contains Swift Code** flag in your project to **Yes** (found under **Build Options** in the **Build Settings** tab).



## Requirements

#### API Key

In order to interact with the AirMap SDK, you will an AirMap API key.  You can aquire an API key by visiting: [http://airmap.com/makers/](https://airmap.com/makers)

#### MapBox Api Key

The Create Flight UI uses the MapBox GL Native SDK.  Please request a MapBox Access Token: [https://www.mapbox.com/ios-sdk/#access_tokens](https://www.mapbox.com/ios-sdk/#access_tokens) 


## Initializing The SDK

An API key & auth token are required to use the AirMap SDK. Sign up via the [AirMap developer portal](https://www.airmap.com/makers/) for access.

```swift
import AirMap

// After Authentication with AirMap, configure AirMapSDK

AirMap.configure(apiKey: "<#API Key#>")
AirMap.trafficDelegate = self // if you want traffic

// Set MapBox Access Token 
// Get an access token: https://www.mapbox.com/ios-sdk/#access_tokens
MGLAccountManager.setAccessToken("<#MapBox Access Token#>")
```
## Authentication

We have provided a convenience UI for authenticating with the AirMap service.


```swift

// Create an instance of the AuthViewController and set the AirMapFlightPlanDelegate
let authViewController = AirMap.authViewController(airMapAuthSessionDelegate: self)

// Present it
presentViewController(authViewController, animated: true, completion: nil)

func airmapSessionShouldReauthenticate(handler: ((token: String) -> Void)?) {
	...
}

func airMapAuthSessionDidAuthenticate(pilot: AirMapPilot) {
	dismissViewControllerAnimated(true, completion: { 
		... 
	})
}

func airMapAuthSessionAuthenticationDidFail(error: NSError) {
	print(error.localizedDescription)
}
```


## Flights

#### Create Flight

***We have provided a Flight Creation UI for convenience***

```swift

let coordinate = 
		CLLocationCoordinate2D(latitude: <#T##CLLocationDegrees#>, longitude: <#T##CLLocationDegrees#>)


let flightPlanNav = AirMap.flightPlanViewController(nil, location: mapView.centerCoordinate, flightPlanDelegate: self)

presentViewController(flightPlanNav, animated: true, completion: nil)

func airMapFlightPlanDidCreate(flight: AirMapFlight) {

	// Close the Flight Creation Form
	dismissViewControllerAnimated(true, completion: nil)
		// Do someting with the flight
		...		
	}
	
	func airMapFlightPlanDidEncounter(error: ErrorType) {
		// Handle Error
		...
	}

```

***Constuct an AirMap Flight Manually***

```

let flight = AirMapFlight()
flight.startTime = NSDate()
flight.endTime = NSDate().dateByAddingTimeInterval(360)
flight.coordinate.latitude = 34.0168106
flight.coordinate.longitude = -118.4972862
flight.maxAltitude = 100
flight.buffer = 1000
flight.isPublic = true

AirMap.createFlight(flight: flight) { (flight, error) in
    if let error = error {
        print(error)
    } else {
        print(flight)
    }
}

```

#### End Flight

```swift
AirMap.end(flight) { flight, error in
	if let error = error {
		print(error)
	}
	
	if let flight = flight {
		print(flight)
	}
}
```

#### List Public & Authenticated User Flights

```swift
AirMap.listAllPublicAndAuthenticatedUserFlights() { flights, error in
	if let error = error {
		print(error)
	} else {
		print(flight)
	}
}
```

#### List Pilot Flights

```swift
AirMap.listFlights(pilot) { flights, error in
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

let currentPosition = CLLocationCoordinate2D(latitude: 34.0168106, longitude: -118.4972862)

AirMap.sendTelemetryData(
	flight, 
	coordinate: currentPosition, 
	altitude: 100, 
	groundSpeed: 5, 
	trueHeading: 090, 
	baro: 1_031.21)
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
	            print(traffic.description) // N954R 3 mi NW 0 min 20 sec 
	            
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

AirMap.checkCoordinate(coordinate, buffer:1000) { (status, error) in
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

let takeoffPoint = CLLocationCoordinate2D(latitude: 41.00, longitude: -109.50)

AirMapClient.checkFlightPath(geometry, width: 1, takeOffPoint: takeoffPoint) { status, error in
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

let takeoffPoint = CLLocationCoordinate2D(latitude: 41.00, longitude: -109.50)


AirMapClient.checkPolygon(geometry, takeOffPoint: takeoffPoint) { status, error in
	if let error = error {
		print(error)
	} else {
		print(status)
	}
}
```

## License

See [LICENSE](https://raw.githubusercontent.com/airmap/AirMapSDK-Swift/master/LICENSE) for details