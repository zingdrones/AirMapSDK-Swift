//
//  Airmap+Log.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 6/28/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import Log

extension AirMap {
	
	#if os(Linux)
		// TODO: Integrate Linux compatible Logging
	#else
		public static let logger = Logger(formatter: Formatter("AirMapSDK %@: %@", [.level, .message]), minLevel: .warning)
	#endif
}
