# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "knife-proxmox"
  s.version = "0.0.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Jorge Moratilla"]
  s.date = "2012-12-01"
  s.description = "Proxmox is a very powerful Virtualization Environment.  Used with chef, you can manage servers and configure them with automatically."
  s.email = "jorge@moratilla.com"
  s.extra_rdoc_files = ["README", "LICENSE", "TODO", "CHANGELOG"]
  s.files = ["CHANGELOG", "TODO", "LICENSE", "knife-proxmox.gemspec", "extra/rebuild-gem.sh", "lib/chef/knife/proxmox_server_stop.rb", "lib/chef/knife/proxmox_server_start.rb", "lib/chef/knife/proxmox_base.rb", "lib/chef/knife/proxmox_template_available.rb", "lib/chef/knife/proxmox_server_destroy.rb", "lib/chef/knife/proxmox_server_list.rb", "lib/chef/knife/proxmox_server_create.rb", "lib/chef/knife/proxmox_template_list.rb", "lib/knife-proxmox/version.rb", "samples/stop_one_task_example.txt", "samples/storage_list_content_example.txt", "samples/results.txt", "samples/available_templates_to_install_example.txt", "samples/tasks_example.txt", "samples/download_template_example.txt", "samples/create_openvz_example.txt", "samples/ProxmoxAPITest.rb", "samples/get_task_status_example.txt", "samples/Rakefile", "Rakefile", "README"]
  s.homepage = "http://www.moratilla.com"
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.15"
  s.summary = "ProxmoxVE Support for Chef's Knife Command"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<rspec>, ["~> 2.0.0"])
      s.add_runtime_dependency(%q<chef>, [">= 0.10.10"])
      s.add_runtime_dependency(%q<rest-client>, [">= 1.6.7"])
      s.add_runtime_dependency(%q<json>, [">= 1.6.1"])
    else
      s.add_dependency(%q<rspec>, ["~> 2.0.0"])
      s.add_dependency(%q<chef>, [">= 0.10.10"])
      s.add_dependency(%q<rest-client>, [">= 1.6.7"])
      s.add_dependency(%q<json>, [">= 1.6.1"])
    end
  else
    s.add_dependency(%q<rspec>, ["~> 2.0.0"])
    s.add_dependency(%q<chef>, [">= 0.10.10"])
    s.add_dependency(%q<rest-client>, [">= 1.6.7"])
    s.add_dependency(%q<json>, [">= 1.6.1"])
  end
end
