# Uncomment the next line to define a global platform for your project
platform :ios, '11.0'
inhibit_all_warnings!
target 'ios-voiceroomsdk-quickdemo' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!
  pod 'RCVoiceRoomLib', :path => '../../gerrit-repo/rcvoiceroomlib-ios'
  pod 'Masonry'
  pod 'SVProgressHUD'
  pod 'YYModel'
  pod 'AFNetworking'
  
  # RTC
  pod 'RongCloudRTC/RongRTCLib', '5.2.4.1'
  pod 'RongCloudRTC/RongRTCPlayer', '5.2.4.1'
  
  # Pods for ios-voiceroomsdk-quickdemo

  target 'ios-voiceroomsdk-quickdemoTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'ios-voiceroomsdk-quickdemoUITests' do
    # Pods for testing
  end

end

post_install do |installer|
  installer.pods_project.build_configurations.each do |config|
    config.build_settings["EXCLUDED_ARCHS[sdk=iphonesimulator*]"] = "arm64"
  end
end
