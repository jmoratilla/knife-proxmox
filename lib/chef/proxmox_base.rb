require 'chef/knife'

class Chef
  class Knife
    module ProxmoxBase
      
      @site = nil
      @auth_params = nil
      
      
      def self.included(includer)
        includer.class_eval do
          
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
        end
      end

      def connection
        @site = RestClient::Resource.new(Chef::Config[:knife][:pve_cluster_url])
        @auth_params ||= begin
          ticket = nil
          csrf_prevention_token = nil
          @site['access/ticket'].post :username=>Chef::Config[:knife][:pve_user_name],
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
      end
    end
  end
end