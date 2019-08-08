//
//  Airmap+Log.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 6/28/16.
//  Copyright 2018 AirMap, Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import Logging

extension AirMap {
	
	public static var logger = Logger(label: "com.airmap.airmapsdk") { (name) -> LogHandler in
		return AirMapLogger(metadata: [:], logLevel: .warning)
	}
}

public struct AirMapLogger: LogHandler {

	public var metadata: Logger.Metadata
	public var logLevel: Logger.Level

	public subscript(metadataKey key: String) -> Logger.Metadata.Value? {
		get {
			return metadata[key]
		}
		set(newValue) {
			metadata[key] = newValue
		}
	}

	private static let dateFormatter = ISO8601DateFormatter()

	public func log(level: Logger.Level, message: Logger.Message, metadata: Logger.Metadata?, file: String = #file, function: String = #function, line: UInt = #line) {
		guard logLevel <= level else {
			return
		}
		print(
			AirMapLogger.dateFormatter.string(from: Date()),
			"AirMapSDK",
			"[\(String(describing: level).uppercased())]:",
			message,
			metadata?.description ?? ""
		)
	}
}
