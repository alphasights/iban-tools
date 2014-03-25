# vim:ts=2:sw=2:et:

require 'rubygems'
require 'bundler/setup'
require 'appraisal'
gem 'rspec', '>= 1.2.4'
require 'rspec/core/rake_task'

task :default => :core

RSpec::Core::RakeTask.new(:core) do |spec|
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rspec_opts = ['--backtrace']
end
