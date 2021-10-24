#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = 'image_gallery_saver'
  s.version          = '1.0.0'
  s.summary          = 'An image gallery saver plugin'
  s.description      = 'An image gallery saver plugin'
  s.homepage         = 'https://opensource.improvising.io'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Improvising Rhythm Ltd.' => 'opensource@improvising.io' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'

  # Flutter.framework does not contain a i386 slice. Only x86_64 simulators are supported.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'VALID_ARCHS[sdk=iphonesimulator*]' => 'x86_64' }
  s.swift_version = '5.0'
end
