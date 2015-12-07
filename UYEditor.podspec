#
# Be sure to run `pod lib lint UYEditor.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "UYEditor"
  s.version          = "0.2"
  s.summary          = "UYEditor"
  s.description      = <<-DESC
                       UYEditor v0.2
                       DESC

  s.homepage         = "http://gitlab.corp.cimu.com/youyu/UYEditor"
  s.license          = 'MIT'
  s.author           = { "winddpan" => "winddpan@126.com" }
  s.source           = { :git => "http://gitlab.corp.cimu.com/youyu/UYEditor", :tag => s.version.to_s }

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.resources = 'HTML/*', 'iOS/UYEditor.xcassets'
  s.source_files = 'iOS/Source/*' 
  s.frameworks = 'UIKit', 'Foundation'
end
