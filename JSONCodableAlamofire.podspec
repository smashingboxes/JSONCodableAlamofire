Pod::Spec.new do |s|
  s.name         = "JSONCodableAlamofire"
  s.version      = "0.1.0"
  s.summary      = "JSONCodable-ify your Alamofire responses"
  s.description  = <<-DESC
  Because you've got to `case .success(let myModelObject):`
                   DESC

  s.homepage     = "https://github.com/smashingboxes/JSONCodableAlamofire"
  s.license      = { type: "MIT", file: "LICENSE" }
  s.author             = { "David Sweetman" => "david@davidsweetman.com" }

  s.ios.deployment_target = "9.0"
  s.osx.deployment_target = "10.10"

  s.source       = { :git => "https://github.com/smashingboxes/JSONCodableAlamofire.git", :tag => "#{s.version}" }

  s.source_files  = "JSONCodableAlamofire/**/*.{swift}"
  s.dependency "Alamofire", "~> 4.4.0"
  s.dependency "JSONCodable", "~> 3.0.1"
end
