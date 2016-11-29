//
//  AirMapStatus.swift
//  AirMapSDK
//
//  Created by Rocky Demoff on 6/13/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import ObjectMapper

@objc public class AirMapStatus: NSObject {

	public enum StatusColor: String {
		case Red    = "red"
		case Yellow = "yellow"
		case Green  = "green"
		case Gray   = "gray"
		
		public static var allColors: [StatusColor] {
			return [.Red, .Yellow, .Green, .Gray]
		}
		
		public var description: String {
			switch self {
			case .Red:
				return "Flight Strictly Regulated"
			case .Yellow:
				return "Advisories"
			case .Green, .Gray:
				return "Informational"
			}
		}
	}

	public private(set) var maxSafeDistance = 0
	public private(set) var advisoryColor = StatusColor.Gray
	public private(set) var advisories = [AirMapStatusAdvisory]()
	public private(set) var applicablePermits = [AirMapAvailablePermit]()
	public private(set) var organizations = [AirMapOrganization]()
	public private(set) var weather: AirMapStatusWeather?
	
	public required init(_ map: Map) {}

	public var requiresPermits: Bool {
		return availablePermits.count > 0
	}
	
	public var supportsDigitalNotice: Bool {
		
        let adv:[AirMapStatusAdvisory] = advisories
            .map { advisory in
                if let notice = advisory.requirements?.notice?.digital {
                    if let organization = organizations.filter ({ $0.id == advisory.organizationId }).first {
                        advisory.organization = organization
                        advisory.requirements!.notice!.digital = true
                    }
                }
                return advisory
            }
            .filterDuplicates { (left, right) in
                let notNil = left.organizationId != nil && right.organizationId != nil
                return notNil && left.organizationId == right.organizationId
            }
    
        return adv
            .flatMap { $0.requirements?.notice }
            .count > 0
	}
	
	public var availablePermits: [AirMapAvailablePermit] {
		return Array(Set(advisories.flatMap { $0.availablePermits }))
	}
	
	public func availablePermitsFor(organization: AirMapOrganization) -> [AirMapAvailablePermit] {
		return availablePermits.filter {
			$0.organizationId == organization.id
		}
	}
	
	public func applicablePermitsFor(organization: AirMapOrganization) -> [AirMapAvailablePermit] {
		return applicablePermits.filter {
			$0.organizationId == organization.id
		}
	}
}

extension AirMapStatus: Mappable {

	public func mapping(map: Map) {
		organizations     <- map["organizations"]
		maxSafeDistance   <- map["max_safe_distance"]
		advisories        <- map["advisories"]
		weather           <- map["weather"]
		advisoryColor     <- map["advisory_color"]
		applicablePermits <- map["applicable_permits"]
		
		advisories.forEach { advisory in
			advisory.organization = organizations.filter { $0.id == advisory.organizationId }.first
			advisory.availablePermits.forEach { permit in
				permit.organizationId = advisory.organizationId!
			}
		}
	}
}
