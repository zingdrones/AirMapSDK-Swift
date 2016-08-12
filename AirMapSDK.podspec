
Pod::Spec.new do |s|
	
	s.name              = 'AirMapSDK'
	s.module_name       = 'AirMap'
	s.author            = 'AirMap, Inc.'
	s.version           = '0.1.1'
	s.summary           = 'AirMap SDK for iOS'
	s.description       = 'Create Flights, Send Telemetry Data, Get Realtime Traffic Alerts.'
	s.license           = { :type => 'MIT', :file => 'LICENSE' }
	s.homepage          = 'https://www.airmap.com/makers/'
	s.documentation_url = 'https://airmap.readme.io'
	s.social_media_url  = 'https://twitter.com/AirMapIO'
	s.source = {
		:git => 'https://github.com/AirMap/AirMapSDK-Swift.git',
		:tag => s.version.to_s
	}
	s.cocoapods_version = '>= 1.0.0'
	s.frameworks = 'Foundation'
	
	s.ios.deployment_target = '8.0'
	s.osx.deployment_target = '10.10'
	
	s.default_subspecs = 'Core', 'Traffic', 'Telemetry', 'UI'

	s.subspec 'Core' do |core|
		core.ios.frameworks = 'UIKit'
		core.osx.frameworks = 'AppKit'
		core.source_files = ['Source/Core/**/{*.h,*.m,*.swift}', 'Source/Rx/*']
		core.dependency 'Alamofire'
		core.dependency 'JWTDecode'
		core.dependency 'SimpleKeychain'
		core.dependency 'Log'
		core.dependency 'ObjectMapper'
		core.dependency 'RxCocoa'
		core.dependency 'RxSwift'
		core.dependency 'RxSwiftExt'
		core.resources = ['Source/Resources/*.cer', 'Source/Resources/*.pdf', 'Source/Resources/*.xcassets']
	end
	
	s.subspec 'UI' do |ui|
		ui.platform = :ios
		ui.frameworks = 'UIKit'
		ui.dependency 'AirMapSDK/Core'
		ui.dependency 'libPhoneNumber-iOS'
		ui.dependency 'Mapbox-iOS-SDK', '~> 3.3.3'
		ui.dependency 'RxDataSources'
		ui.source_files = 'Source/UI/**/{*.swift}'
		ui.resources = ['Source/UI/**/{*.storyboard,*.xcassets}']
	end
	
	s.subspec 'Traffic' do |traffic|
		traffic.xcconfig = { 'OTHER_SWIFT_FLAGS' => '$(inherited) -DAIRMAP_TRAFFIC' }
		traffic.dependency 'AirMapSDK/Core'
		traffic.dependency 'SwiftMQTT'
		traffic.source_files = 'Source/Traffic/*'
	end
	
	s.subspec 'Telemetry' do |telemetry|
		telemetry.xcconfig = { 'OTHER_SWIFT_FLAGS' => '$(inherited) -DAIRMAP_TELEMETRY' }
		telemetry.dependency 'AirMapSDK/Core'
		telemetry.dependency 'CocoaAsyncSocket'
		telemetry.dependency 'CryptoSwift'
		telemetry.dependency 'ProtocolBuffers-Swift'
		telemetry.source_files = 'Source/Telemetry/*'
	end
	
end
