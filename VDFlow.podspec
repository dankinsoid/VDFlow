#
# Be sure to run `pod lib lint VDUIExtensions.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'VDFlow'
  s.version          = '2.30.0'
  s.summary          = 'A short description of VDFlow.'
  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/dankinsoid/VDFlow'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Voidilov' => 'voidilov@gmail.com' }
  s.source           = { :git => 'https://github.com/dankinsoid/VDFlow.git', :tag => s.version.to_s }

  s.ios.deployment_target = '13.0'
  s.macos.deployment_target = '10.15'
  s.swift_versions = '5.5'
  s.source_files = 'Sources/VDFlow/**/*'
  s.dependency 'IterableView', '~> 1.0.0'
end
