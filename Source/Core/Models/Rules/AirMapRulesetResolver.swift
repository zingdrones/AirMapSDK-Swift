//
//  AirMapRulesetResolver.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 5/17/18.
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

import Foundation

public class AirMapRulesetResolver {

	/// Takes a list of ruleset preferences and resolves which rulesets should be enabled from the available jurisdictions
	///
	/// - Parameters:
	///   - preferredRulesetIds: An array of rulesets ids, if any, that the user has previously selected
	///   - jurisdictions: An array of jurisdictions for the area of operation
	///   - recommendedEnabledByDefault: A flag that enables all recommended airspaces by default.
	/// - Returns: A resolved array of rulesets taking into account the user's .optional and .pickOne selection preference
	public static func resolvedActiveRulesets(with preferredRulesetIds: [AirMapRulesetId] = [], from jurisdictions: [AirMapJurisdiction], enableRecommendedRulesets: Bool = true) -> [AirMapRuleset] {

		var rulesets = [AirMapRuleset]()

		// always include the required rulesets (e.g. TFRs, restricted areas, etc)
		rulesets += jurisdictions.requiredRulesets

		// if the preferred rulesets contains an .optional ruleset, add it to the array
		rulesets += jurisdictions.optionalRulesets
			.filter({ !jurisdictions.airMapRecommendedRulesets.contains($0) })
			.filter({ preferredRulesetIds.contains($0.id) })

		// if the preferred rulesets contains an .optional AirMap recommended ruleset, add it to the array
		// if the only ruleset is an AirMap recommended ruleset, add it as well
		rulesets += jurisdictions.airMapRecommendedRulesets
			.filter({ enableRecommendedRulesets || preferredRulesetIds.contains($0.id) || jurisdictions.rulesets.count == 1 })

		// for each jurisdiction, determine if a preferred .pickOne has been selected otherwise take the default .pickOne
		for jurisdiction in jurisdictions {
			guard let defaultPickOneRuleset = jurisdiction.defaultPickOneRuleset else { continue }
			if let preferredPickOne = jurisdiction.pickOneRulesets.first(where: { preferredRulesetIds.contains($0.id) }) {
				rulesets.append(preferredPickOne)
			} else {
				rulesets.append(defaultPickOneRuleset)
			}
		}

		return rulesets
	}
}
