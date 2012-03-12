# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "inactiverecord/version"

Gem::Specification.new do |s|
  s.name        = "inactiverecord"
  s.version     = Inactiverecord::VERSION
  s.authors     = ["Dan Cunning"]
  s.email       = ["dan@topdan.com"]
  s.homepage    = ""
  s.summary     = %q{ActiveRecord and ActiveModel API without database persistence}
  s.description = %q{ActiveRecord and ActiveModel API without database persistence}

  s.rubyforge_project = "inactiverecord"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  # s.add_development_dependency "rspec"
  # s.add_runtime_dependency "rest-client"
  
  s.add_dependency 'activemodel'
  s.add_development_dependency "rspec"
  s.add_development_dependency "rcov"
end
