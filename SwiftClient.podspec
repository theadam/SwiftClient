Pod::Spec.new do |s|
  s.name = 'SwiftClient'
  s.version = '3.0.0'
  s.license = 'MIT'
  s.summary = 'A simple HTTP client library written in Swift 3'
  s.homepage = 'https://github.com/theadam/SwiftClient'
  s.authors = { 'Adam Nalisnick' => 'theadam4257@gmail.com', 'Sandro Machado' => 'sandroemachado@gmail.com' }
  s.source = { :git => 'https://github.com/theadam/SwiftClient.git', :tag => s.version }
  s.ios.deployment_target = '9.0'
  s.source_files = 'Sources/*.swift'
  s.requires_arc = true
end
