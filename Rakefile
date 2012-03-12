require "bundler/gem_tasks"
require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new('spec')

rcov_opts = '--exclude osx\/objc,cucumber.rb,cucumber\/,gems\/,spec\/,features\/ --failure-threshold 100'

namespace :rcov do
  desc "Run all specs with rcov"
  RSpec::Core::RakeTask.new(:spec) do |t|
    t.rcov = true
    t.pattern = "./spec/**/*_spec.rb"
    t.rcov_opts = rcov_opts
  end
  
  task :all => 'rcov:spec'
end
