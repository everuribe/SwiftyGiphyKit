#
#  Be sure to run `pod spec lint SwiftyGiphyKit.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |spec|

  spec.name = "SwiftyGiphyKit"
  spec.version = "0.1.1"
  spec.summary = "Lightweight Swift kit used to present Giphy search/picker view and display/edit GIFs in a user-interactable image view powered by SwiftyGif."

  spec.description = <<-DESC
  Lightweight Swift kit used to present Giphy search/picker view and display/edit GIFs in a user-interactable image view (UIImageView) powered by SwiftyGif.
                   DESC

  spec.homepage  = "https://github.com/everuribe/SwiftyGiphyKit"

  spec.license = { :type => "MIT", :file => "LICENSE" }

  spec.author = { "Ever" => "e.apollo.u@gmail.com" }

  spec.ios.deployment_target = "12.0"

  spec.swift_version = "5.1"

  spec.source = { :git => "https://github.com/everuribe/SwiftyGiphyKit.git", :tag => "#{spec.version}" }

  spec.source_files = "SwiftyGiphyKit/**/*.{h,m,swift}"

  spec.resources = "SwiftyGiphyKit/*.xcassets"

  spec.dependency 'SwiftyGif'

end
