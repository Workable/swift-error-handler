Pod::Spec.new do |s|
  s.name         = "ErrorHandler"
  s.version      = "0.8.0"
  s.summary      = "Error handling library for Swift"
  s.description  = <<-DESC
  > Elegant and flexible error handling for Swift

ErrorHandler enables expressing complex error handling logic with a few lines of code using a memorable fluent API.
  DESC
  s.homepage     = "https://github.com/Workable/swift-error-handler"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.authors             = { "Kostas Kremizas" => "kremizask@gmail.com",
                            "Eleni Papanikolopoulou" => "eleni.papanikolopoulou@gmail.com" }
  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.10'
  s.watchos.deployment_target = '2.0'
  s.tvos.deployment_target = '9.0'
  s.source       = { :git => "https://github.com/Workable/swift-error-handler.git", :tag => s.version.to_s }

  s.default_subspec = "Core"

  s.subspec "Core" do |ss|
    ss.source_files  = "ErrorHandler/Classes/Core/**/*"
    ss.framework  = "Foundation"
  end

  s.subspec "Alamofire" do |ss|
    ss.source_files = "ErrorHandler/Classes/Alamofire/**/*"
    ss.dependency "Alamofire", "~> 4.1"
    ss.dependency "ErrorHandler/Core"
  end
end
