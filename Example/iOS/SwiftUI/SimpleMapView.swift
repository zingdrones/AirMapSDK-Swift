//
//  SimpleMapView.swift
//  AirMapSDK-Example-iOS
//
//  Created by Michael Odere on 10/28/19.
//  Copyright © 2019 AirMap, Inc. All rights reserved.
//

import AirMap
import Mapbox
import SwiftUI

private struct SimpleMapView: UIViewRepresentable {
	private let mapView = AirMapMapView(frame: .zero)
	
	func makeUIView(context: UIViewRepresentableContext<SimpleMapView>) -> AirMapMapView {
		let token = AirMap.configuration.mapboxAccessToken!
		MGLAccountManager.accessToken = token
	
        return mapView
	}
	
	func updateUIView(_ uiView: AirMapMapView, context: UIViewRepresentableContext<SimpleMapView>) {}
}

struct SimpleMapContentView: View {
	 var body: some View {
		 SimpleMapView()
			.navigationBarTitle(Text(verbatim: "Simple Map"), displayMode: .inline)
			.edgesIgnoringSafeArea(.all)
	 }
}

struct SimpleMapContentView_Previews: PreviewProvider {
    static var previews: some View {
        SimpleMapContentView()
    }
}
