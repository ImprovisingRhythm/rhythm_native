#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint scan.podspec' to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'scan'
  s.version          = '1.0.0'
  s.summary          = 'A qrcode scanner plugin'
  s.description      = 'A qrcode scanner plugin'
  s.homepage         = 'https://opensource.improvising.io'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Improvising Rhythm Ltd.' => 'opensource@improvising.io' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '11.0'

  # Flutter.framework does not contain a i386 slice. Only x86_64 simulators are supported.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'VALID_ARCHS[sdk=iphonesimulator*]' => 'x86_64' }
  s.swift_version = '5.0'
end
