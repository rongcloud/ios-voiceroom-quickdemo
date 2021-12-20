# Uncomment the next line to define a global platform for your project
platform :ios, '13.0'
inhibit_all_warnings!
target 'ios-voiceroomsdk-quickdemo' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!
 pod 'RCVoiceRoomLib'
  pod 'Masonry'
  pod 'SVProgressHUD'
  pod 'YYModel'
  pod 'AFNetworking'
  
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
