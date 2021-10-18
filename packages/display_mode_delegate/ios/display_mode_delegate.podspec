#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint flutter_displaymode.podspec' to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'display_mode_delegate'
  s.version          = '1.0.0'
  s.summary          = 'A Flutter plugin to set display mode in Android'
  s.description      = 'A Flutter plugin to set display mode in Android'
  s.homepage         = 'https://improvising.io'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Improvising Rhythm, Ltd.' => 'opensource@improvising.io' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '8.0'

  # Flutter.framework does not contain a i386 slice. Only x86_64 simulators are supported.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'VALID_ARCHS[sdk=iphonesimulator*]' => 'x86_64' }
  s.swift_version = '5.0'
end
