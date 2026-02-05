Pod::Spec.new do |s|
  s.name             = 'direct_calling'
  s.version          = '1.2.0'
  s.summary          = 'A Flutter plugin for making direct phone calls (Android, iOS & Web).'
  s.description      = 'A Flutter plugin for making direct phone calls on Android, iOS, and Web with proper permission handling.'
  s.homepage         = 'https://github.com/direct_calling/direct_calling'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Direct Calling' => 'direct_calling@example.com' }
  s.source           = { :path => '.' }
  s.source_files     = 'ios/Classes/**/*'
  s.ios.deployment_target = '12.0'
  s.swift_version = '5.0'
  s.dependency 'Flutter'

  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
end
