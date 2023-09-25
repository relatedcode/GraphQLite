Pod::Spec.new do |s|
  s.name = 'GraphQLite'
  s.version = '1.2.8'
  s.license = 'MIT'

  s.summary = 'GraphQLite is a toolkit to work with GraphQL servers easily.'
  s.homepage = 'https://relatedcode.com'
  s.author = { 'Related Code' => 'info@relatedcode.com' }

  s.source = { :git => 'https://github.com/relatedcode/GraphQLite.git', :tag => s.version }
  s.source_files = 'ios-sdk/Sources/**/*.swift'

  s.pod_target_xcconfig = { 'SWIFT_VERSION' => '5.0' }

  s.swift_version = '5.0'
  s.platform = :ios, '13.0'
  s.requires_arc = true
end
