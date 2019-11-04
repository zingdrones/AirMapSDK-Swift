//
//  ExamplesView.swift
//  AirMapSDK-Example-iOS
//
//  Created by Michael Odere on 10/29/19.
//  Copyright © 2019 AirMap, Inc. All rights reserved.
//

import SwiftUI

struct Example {
	let name: String
	let info: String
	let view: AnyView
}

extension Example: Identifiable {
	var id: String {
		return name
	}
}

struct ExamplesView: View {
	private var examples: [Example] =
		[
			Example(
				name: "Simple Map View",
				info: "Display an AirMap map that automatically configures itself to display airspace",
				view: AnyView(SimpleMapContentView())
			),
			Example(
				name: "Custom Map Airspace Styling",
				info: "Display an AirMap map with custom overrides for airspace layer styles",
				view: AnyView(CustomMapContentView())
			),
			Example(
				name: "Advanced Map Rulesets, Advisories",
				info: "Query the jurisdictions that intersect the map's viewport and displays a picker for the user to select the rulesets under which they wish to operate. Display relevant advisories for the map's area and rulesets selected",
				view: AnyView(SimpleMapContentView())
			),
			Example(
				name: "AirMap User Authentication",
				info: "Present a login UI to sign up or login a user, then display the authenticated pilot's information.",
				view: AnyView(SimpleMapContentView())
			),
			Example(
				name: "Anonymous Login",
				info: "Perform an anonymous login without an existing AirMap pilot.",
				view: AnyView(SimpleMapContentView())
			)
		]

	var body: some View {
		NavigationView {
			List(examples) { example in
				ExampleCell(example: example)
			}
			.navigationBarTitle(Text("Examples"))
		}
	}

}

struct ExampleCell: View {
	let example: Example

	var body: some View {
		return NavigationLink(destination: example.view) {
			VStack(alignment: .leading) {
				Text(example.name)
					.font(.headline)
					.padding(EdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0))
				Text(example.info)
					.font(.body)
			}
		}

	}
}

struct ExamplesView_Previews: PreviewProvider {
	static var previews: some View {
		ExamplesView()
	}
}
