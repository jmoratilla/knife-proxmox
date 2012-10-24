# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "knife-proxmox/version"

#TODO: Create a good gem using this tutorial http://guides.rubygems.org/make-your-own-gem/#writing-tests
Gem::Specification.new do |s|
  s.name        = "knife-proxmox"
  s.version     = Knife::Proxmox::VERSION
  s.has_rdoc = false
  s.authors     = ["Jorge Moratilla"]
  s.email       = ["jorge@moratilla.com"]
  s.homepage = "http://wiki.opscode.com/display/chef"
  s.summary = "ProxmoxVE Support for Chef's Knife Command"
  s.description = s.summary
  s.extra_rdoc_files = ["README", "LICENSE","TODO","CHANGELOG" ]

  s.files         = Dir['lib/**/*.rb'] + Dir['./*']
  s.add_dependency "chef", ">= 0.10.10"
  s.add_dependency "rest-client", ">=1.6.7"
  s.add_dependency "json", ">=1.6.1"
  s.require_paths = ["lib"]

end
