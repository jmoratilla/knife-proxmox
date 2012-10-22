#require 'chef/knife/proxmox_base'
require 'rubygems'
require 'rest_client'
require 'json'

class Chef
  class Knife
    class ProxmoxTemplateList < Knife
      
      banner "knife proxmox template list (options)"
      
          
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
      
      def run
        site = nil
        auth_params = nil
        
        template_list = [
          ui.color('Name', :bold),
          ui.color('Size', :bold)
        ]
        # FIXME: storage = local debería ser tambien un parametro configurable
        site = RestClient::Resource.new(Chef::Config[:knife][:pve_cluster_url])
        auth_params ||= begin
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
                token = 'PVEAuthCookie=' + ticket.gsub!(/:/,'%3A').gsub!(/=/,'%3D')
              end
            end
          end
          {:CSRFPreventionToken => csrf_prevention_token, :cookie => token} 
        end
        
        site["nodes/#{Chef::Config[:knife][:pve_node_name]}/storage/local/content"].get auth_params do |response, request, result, &block|
          JSON.parse(response.body)['data'].each { |entry|
            if entry['content'] == 'vztmpl' then
              template_list << entry['volid']
              template_list << (entry['size'].to_i/1048576).to_s + " MB"
            end
          }
        end
        puts ui.list(template_list, :uneven_columns_across, 2)
      end
    end
  end
end