#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = 'flutter_branch_sdk'
  s.version          = '0.0.1'
  s.summary          = 'Flutter Plugin for Brach Metrics SDK - https:&#x2F;&#x2F;branch.io'
  s.description      = <<-DESC
Flutter Plugin for Brach Metrics SDK - https:&#x2F;&#x2F;branch.io
                       DESC
  s.homepage         = 'https://github.com/RodrigoSMarques'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Rodrigo Marques' => 'rodrigosmarques@gmail.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.dependency 'Branch'
  s.ios.deployment_target = '8.0'
  s.swift_version = '4.2'
end

