#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint flutter_branch_sdk.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'flutter_branch_sdk'
  s.version          = '3.0.0'
  s.summary          = 'Flutter Plugin for create deep link using Brach SDK (https://branch.io). This plugin provides a cross-platform (iOS, Android, Web).'
  s.description      = <<-DESC
Flutter Plugin for create deep link using Brach SDK (https://branch.io). This plugin provides a cross-platform (iOS, Android, Web).
                       DESC
  s.homepage         = 'https://github.com/RodrigoSMarques/flutter_branch_sdk'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Rodrigo S. Marques' => 'rodrigosmarques@gmail.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.dependency 'Branch', '~> 1.43.0'
  s.platform = :ios, '9.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
