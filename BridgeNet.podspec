#
# Be sure to run `pod lib lint Bridge.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'BridgeNet'
  s.version          = '0.1.0'
  s.summary          = 'Library for sending messages within the application, replacing for the NotificationCenter and Observer Observable pattern'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
The Pod is a representation of the messages delivery system within the app.
It can replace the NotificationCenter or Observer Observable pattern.
Using this library, you can send messages in a thread safety environment to
any object on your app confirming Bridge protocols. It is flexible and keeping
all your objects independent and testable.
                       DESC

  s.homepage         = 'https://github.com/pichukov/Bridge'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'pichukov' => 'pichukov@gmail.com' }
  s.source           = { :git => 'https://github.com/pichukov/Bridge.git', :tag => s.version }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '11.0'
  s.swift_version = '4.2'

  s.source_files = '*.{swift}'
  
  # s.resource_bundles = {
  #   'Bridge' => ['Bridge/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
