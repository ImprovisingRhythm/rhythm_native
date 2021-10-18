#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint flutter_image_picker.podspec' to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'image_picker'
  s.version          = '1.0.0'
  s.summary          = 'An advanced multi image picker plugin'
  s.description      = 'An advanced multi image picker plugin'
  s.homepage         = 'https://opensource.improvising.io'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Improvising Rhythm, Ltd.' => 'opensource@improvising.io' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.dependency 'ZLPhotoBrowser', '4.1.7'
  s.platform = :ios, '11.0'

  # Flutter.framework does not contain a i386 slice. Only x86_64 simulators are supported.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'VALID_ARCHS[sdk=iphonesimulator*]' => 'x86_64' }
  s.swift_version = '5.0'
end
