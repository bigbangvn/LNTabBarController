Pod::Spec.new do |s|
    s.name         = "LNTabBarController"
    s.version      = "0.1"
    s.license      = "Langnet"
    s.summary      = "Custom tab bar controller for Langnet iOS."
    s.homepage     = "https://github.com/bigbangvn/LNTabBarController"
    s.author       = {"Bang Nguyen" => "trongbangvp@gmail.com"}
    s.source       = {:git => "https://github.com/bigbangvn/LNTabBarController.git", :tag => "0.1"}
    s.source_files = "Source/**/*.swift"
    s.resources    = "Resources/**/*.xcassets"
    s.platform     = :ios, "10.0"
    s.dependency 'SnapKit'
end
