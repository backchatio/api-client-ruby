# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "backchat_client/version"

Gem::Specification.new do |s|
  s.name        = "backchat-client"
  s.version     = BackchatClient::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["This gem provides an easy way to access Backchat provisioning API"]
  s.email       = ["juandebravo@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{Gem to access Backchat provisioning API}
  s.description = %q{Gem to access Backchat provisioning API using rest_client as http client}

  s.rubyforge_project = "backchat-client"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  
  s.add_dependency("rest-client")
  s.add_dependency("libwebsocket")
  s.add_dependency("activesupport")
  s.add_dependency("addressable")  
  s.add_development_dependency('rspec')
  s.add_development_dependency('webmock')
end
