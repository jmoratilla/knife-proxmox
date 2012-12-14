# -*- encoding: utf-8 -*-
require 'rubygems'
#require 'rake/gempackagetask'
require 'rubygems/package_task'

$:.push File.expand_path("../lib", __FILE__)
require "knife-proxmox/version"

gemspec = Gem::Specification.new do |gem|
  gem.platform = Gem::Platform::RUBY
  gem.name = "knife-proxmox"
  gem.summary = %Q{ProxmoxVE Support for Chef's Knife Command}
  gem.description = %Q{Proxmox is a very powerful Virtualization Environment.  Used with chef, you can manage servers and configure them with automatically.}
  gem.version = Knife::Proxmox::VERSION
  gem.email = "jorge@moratilla.com"
  gem.homepage = "http://www.moratilla.com"
  gem.authors = ["Jorge Moratilla"]
  gem.extra_rdoc_files = ["README", "LICENSE", "TODO","CHANGELOG"]
  gem.has_rdoc = false
  
  gem.add_development_dependency "rspec", "~>2.0.0"
  gem.add_dependency "chef", ">= 0.10.10"
  gem.add_dependency "rest-client", ">=1.6.7"
  gem.add_dependency "json", ">=1.6.1"
  gem.require_paths = ["lib"]
  
  files = FileList["**/*"]
  files.exclude /\.DS_Store/
  files.exclude /\#/
  files.exclude /~/
  files.exclude /\.swp/
  files.exclude '**/._*'
  files.exclude '**/*.orig'
  files.exclude '**/*.rej'
  files.exclude /^pkg/
  files.exclude 'ripple.gemspec'
  files.exclude 'Gemfile'
  files.exclude 'spec/support/test_server.yml'

  gem.files = files.to_a

  gem.test_files = FileList["spec/**/*.rb"].to_a
end

# Gem packaging tasks
Gem::PackageTask.new(gemspec) do |pkg|
  pkg.need_zip = false
  pkg.need_tar = false
end

task :gem => :gemspec

desc %{Build the gemspec file.}
task :gemspec do
  gemspec.validate
  File.open("#{gemspec.name}.gemspec", 'w'){|f| f.write gemspec.to_ruby }
end

desc %{Release the gem to RubyGems.org}
task :release => :gem do
  system "gem push pkg/#{gemspec.name}-#{gemspec.version}.gem"
end

=begin
require 'rspec/core'
require 'rspec/core/rake_task'

desc "Run Unit Specs Only"
Rspec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = "spec/ripple/**/*_spec.rb"
end

namespace :spec do
  desc "Run Integration Specs Only"
  Rspec::Core::RakeTask.new(:integration) do |spec|
    spec.pattern = "spec/integration/**/*_spec.rb"
  end

  desc "Run All Specs"
  Rspec::Core::RakeTask.new(:all) do |spec|
    spec.pattern = "spec/**/*_spec.rb"
  end
end
=end

task :default => :spec