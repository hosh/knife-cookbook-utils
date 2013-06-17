$:.unshift(File.dirname(__FILE__) + '/lib')
require 'knife-cookbook-utils/version'

Gem::Specification.new do |s|
  s.name = "knife-cookbook-utils"
  s.version = KnifeCookbookUtils::VERSION
  s.license = 'Apache 2.0'
  s.platform = Gem::Platform::RUBY
  s.has_rdoc = true
  s.extra_rdoc_files = ["README.md", "LICENSE"]
  s.summary = "Prune and manage your cookbooks"
  s.description = s.summary
  s.author = "Ho-Sheng Hsiao"
  s.email = "hosh@opscode.com"
  s.homepage = "http://www.opscode.com"

  s.add_dependency 'chef', ">=11.0.0"
  s.add_dependency 'rlet', '=0.5.1'
  s.add_development_dependency 'rspec'

  s.require_path = 'lib'
  s.files = %w(LICENSE README.md Rakefile) + Dir.glob("{lib,spec}/**/*")
end

