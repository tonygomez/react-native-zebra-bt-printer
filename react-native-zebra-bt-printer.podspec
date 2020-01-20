require "json"

package = JSON.parse(File.read(File.join(__dir__, "package.json")))

Pod::Spec.new do |s|
  s.name         = "react-native-zebra-bt-printer"
  s.version      = package["version"]
  s.summary      = package["description"]
  s.description  = <<-DESC
                  react-native-zebra-bt-printer
                   DESC
  s.homepage     = "https://github.com/tonygomez/react-native-zebra-bt-printer"
  s.license      = "MIT"
  # s.license    = { :type => "MIT", :file => "FILE_LICENSE" }
  s.authors      = { "ViuLogix" => "support@viulogix.com" }
  s.platforms    = { :ios => "9.0" }
  s.source       = { :git => "https://github.com/tonygomez/react-native-zebra-bt-printer", :tag => "#{s.version}" }

  s.source_files = "ios/**/*.{h,m,swift}"
  s.requires_arc = true

  s.dependency "React"
  # ...
  # s.dependency "..."
end

