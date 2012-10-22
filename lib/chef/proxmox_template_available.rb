#require 'chef/knife/proxmox_base'
require 'rubygems'
require 'rest_client'
require 'json'

class Chef
  class Knife
    class ProxmoxTemplateAvailable < Knife

      banner "knife proxmox template available (options)"
      
      site = nil
      auth_params = nil
      
#      def self.included(includer)
#        includer.class_eval do

          deps do
            require 'rubygems'
            require 'rest_client'
            require 'json'
          end

          option :pve_cluster_url,
            :short => "-U URL",
            :long  => "--pve_cluster_url URL",
            :description => "Your URL to access Proxmox VE server/cluster",
            :proc  => Proc.new {|url| Chef::Config[:knife][:pve_cluster_url] = url }

          option :pve_user_name,
            :short => "-u username",
            :long  => "--username username",
            :description => "Your username in Proxmox VE",
            :proc  => Proc.new {|username| Chef::Config[:knife][:pve_user_name] = username }

          option :pve_user_password,
            :short => "-p password",
            :long  => "--password password",
            :description => "Your password in Proxmox VE",
            :proc  => Proc.new {|password| Chef::Config[:knife][:pve_user_password] = password }

          option :pve_user_realm,
            :short => "-R realm",
            :long  => "--realm realm",
            :description => "Your realm of Authentication in Proxmox VE",
            :proc  => Proc.new {|realm| Chef::Config[:knife][:pve_user_realm] = realm }

          option :pve_node_name,
            :short => "-n node",
            :long  => "--node nodename",
            :description => "Proxmox VE server name where you will actuate",
            :proc  => Proc.new {|node| Chef::Config[:knife][:pve_node_name] = node }
#        end
#      end

      def run
        site = RestClient::Resource.new(Chef::Config[:knife][:pve_cluster_url])
        token = nil
        csrf_prevention_token = nil
        site['access/ticket'].post :username=>Chef::Config[:knife][:pve_user_name],
          :realm=>Chef::Config[:knife][:pve_user_realm],
          :password=>Chef::Config[:knife][:pve_user_password] do |response, request, result, &block|
            if response.code == 200 then
              data = JSON.parse(response.body)
              ticket = data['data']['ticket']
              csrf_prevention_token = data['data']['CSRFPreventionToken']
              if !ticket.nil? then
                # Token is a cookie coded like this one
                # 'PVEAuthCookie=PVE%3Atest@pve%3A5079E676%3A%3AE5Btg[...]crcp/RzEitO/vKMvr5YpAmjBRw7HS2IA3Q%3D%3D'
                token = 'PVEAuthCookie=' + ticket.gsub!(/:/,'%3A').gsub!(/=/,'%3D')
              end
            end
        end
        auth_params = {:CSRFPreventionToken => csrf_prevention_token, :cookie => token}

        template_list = [
          ui.color('Name', :bold),
          ui.color('Operating System', :bold)
        ]
        # FIXME: storage = local debería ser tambien un parametro configurable
        site["nodes/#{Chef::Config[:knife][:pve_node_name]}/aplinfo"].get auth_params do |response, request, result, &block|
          JSON.parse(response.body)['data'].each { |entry|
            template_list << entry['template'].strip
            template_list << entry['os'].strip
          }
        end

        puts ui.list(template_list, :uneven_columns_across, 2)
      end
    end
  end
end