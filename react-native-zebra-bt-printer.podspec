require 'json'

package = JSON.parse(File.read(File.join(__dir__, '../package.json')))

Pod::Spec.new do |s|
  s.name              = package['name']
  s.version           = package['version']
  s.summary           = package['description']
  s.license           = package['license']
  s.homepage          = package['homepage']
  s.documentation_url = "https://docs.microsoft.com/en-us/appcenter/"

  s.author            = { 'Tony Gomez' => 'tony@viulogix.com' }

  s.source            = { :git => "https://github.com/tonygomez/react-native-zebra-bt-printer" }
  s.source_files      = "react-native-zebra-bt-printer/**/*.{h,m}"
  s.platform          = :ios, '9.0'
  s.requires_arc      = true


  s.dependency 'React'
end
