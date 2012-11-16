#
# Author:: Adam Jacob (<adam@opscode.com>)
# Author:: Daniel DeLeo (<dan@opscode.com>)
# Copyright:: Copyright (c) 2008, 2010 Opscode, Inc.
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'bundler'
require 'rubygems'
require 'rubygems/package_task'
Bundler::GemHelper.install_tasks


desc "Validate the gemspec"
task :gemspec do
  gemspec.validate
end
 
desc "Build gem locally"
task :build => :gemspec do
  system "gem build #{gemspec.name}.gemspec"
  FileUtils.mkdir_p "pkg"
  FileUtils.mv "#{gemspec.name}-#{gemspec.version}.gem", "pkg"
end

desc "Remove gem locally"
task :remove => :build do
  system "gem uninstall #{gemspec.name}"
end

desc "Install gem locally"
task :install => :remove do
  system "gem install pkg/#{gemspec.name}-#{gemspec.version}"
end


desc "Let's do a full rebuild"
task :rebuild => [:remove, :gemspec, :build, :install]
