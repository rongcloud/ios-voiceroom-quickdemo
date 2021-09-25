#
# Be sure to run `pod lib lint RCVoiceRoomLib.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'RCVoiceRoomLib'
  s.version          = '2.0.0'
  s.summary          = 'A short description of RCVoiceRoomLib.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/zangqilong/RCVoiceRoomLib'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'zangqilong' => 'zangqilong@zerosportsai.com' }
  s.source           = { :git => 'https://github.com/zangqilong/RCVoiceRoomLib.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '9.0'
  
  s.pod_target_xcconfig = {
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64',
    'VALID_ARCHS' => 'arm64 x86_64 armv7',
    'ENABLE_BITCODE' => 'NO'
  }

  s.source_files = 'RCVoiceRoomLib/Classes/**/*'
  
  # s.resource_bundles = {
  #   'RCVoiceRoomLib' => ['RCVoiceRoomLib/Assets/*.png']
  # }

  s.public_header_files = 'Pod/Classes/Header/RCVoiceRoomLib.h'
  # s.frameworks = 'UIKit', 'MapKit'
  s.dependency 'RongCloudRTC/RongRTCLib', '~> 5.1.8'
  s.dependency 'RongCloudIM/IMLib', '~> 5.1.4'
end
