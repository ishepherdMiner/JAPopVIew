Pod::Spec.new do |s|
  s.name         = "JAPopView"
  s.version      = "0.0.1"
  s.summary      = "An pop view"
  s.description  = <<-DESC
  An pop view
                   DESC
  s.homepage     = "https://github.com/ishepherdMiner/JAPopView"
  # s.screenshots  = "www.example.com/screenshots_1.gif", "www.example.com/screenshots_2.gif"
  s.license      = "MIT"
  s.author       = { "Jason" => "iJason92@yahoo.com" }
  s.platform     = :ios, "7.0"
  s.source       = { :git => "https://github.com/ishepherdMiner/JAProgressBar.git", :tag => "#{s.version}" }
  s.source_files =  "JAPopView/*.{h,m}"  

  s.public_header_files = "JAPopView/JAPopView.h"
  s.frameworks   = "UIKit", "QuartzCore","Foundation"
  s.requires_arc = true
  s.module_name  = "JAPopView"
  # s.xcconfig = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/libxml2" }

end
