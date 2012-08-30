# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "memory_record/version"

Gem::Specification.new do |s|
  s.name        = "memory_record"
  s.version     = Inactiverecord::VERSION
  s.authors     = ["Dan Cunning"]
  s.email       = ["dan@topdan.com"]
  s.homepage    = ""
  s.summary     = %q{ActiveModel API without database persistence}
  s.description = %q{ActiveModel API without database persistence}

  s.rubyforge_project = "memory_record"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency 'activemodel'
  s.add_development_dependency 'guard-test'
end
