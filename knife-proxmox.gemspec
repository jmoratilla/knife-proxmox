# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "knife-proxmox/version"

Gem::Specification.new do |s|
  s.name        = "knife-proxmox"
  s.version     = Knife::Proxmox::VERSION
  s.has_rdoc = true
  s.authors     = ["Jorge Moratilla"]
  s.email       = ["jorge@moratilla.com"]
  s.homepage = "http://wiki.opscode.com/display/chef"
  s.summary = "ProxmoxVE Support for Chef's Knife Command"
  s.description = s.summary
  s.extra_rdoc_files = ["README", "LICENSE" ]

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.add_dependency "chef", ">= 0.10.10"
  s.add_dependency "rest_client"
  s.add_dependency "json"
  s.add_dependency "cgi"
  s.require_paths = ["lib"]

end
