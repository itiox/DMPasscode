Pod::Spec.new do |s|
  s.name             = "IPasscode"
  s.version          = "0.9.0"
  s.summary          = "Passcode screen with Touch ID support"
  s.homepage         = "https://github.com/itiox/IPasscode"
  s.license          = 'Public Domain'
  s.author           = { "Javier Alvargonzález" => "javier.alvargonzalez@itiox" }
  s.source           = { :git => "https://github.com/itiox/IPasscode.git", :tag => s.version.to_s }
  s.screenshot  	 = "http://46.105.26.1/uploads/passcode.png"

  s.platform     = :ios, '7.1'
  s.requires_arc = true

  s.source_files = 'Pod/Classes'
  s.resource_bundles = { 'IPasscode' => 'Pod/Assets/*.lproj' }

  s.public_header_files = 'Pod/Classes/IPasscode.h', 'Pod/Classes/IPasscodeConfig.h'
  s.frameworks = 'UIKit', 'Security', 'LocalAuthentication'
end
