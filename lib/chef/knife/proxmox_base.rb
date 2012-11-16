require 'chef/knife'
#TODO: Testing of everything
#TODO: All inputs MUST be checked and errors MUST be catched.
class Chef
  class Knife
    module ProxmoxBase
      
      def self.included(includer)
        includer.class_eval do

          deps do
            require 'rubygems'
            require 'rest_client'
            require 'json'
            require 'chef/json_compat'
            require 'cgi'
            require 'chef/log'
            require 'set'
          end
          
          # options
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
      
      # Checks that the parameter provided is defined in knife.rb
      def check_global_parameter(value)
        if (Chef::Config[:knife][value].nil? or Chef::Config[:knife][value].empty?) then
          ui.error "knife[:#{value.to_s}] is empty, define a value for it and try again"
          exit 1
        end
        Chef::Log.debug("knife[:#{value}] = " + Chef::Config[:knife][value])
      end
      
      def check_config_parameter(value)
        if (config[value].nil? or config[value].empty?) then
          ui.error "--#{value} is empty, define a value for it and try again"
          exit 1
        end
      end
      
      # Establishes the connection with proxmox server
      def connection
        # First, let's check we have all info needed to connect to pve
        [:pve_cluster_url, :pve_node_name, :pve_user_name, :pve_user_password, :pve_user_realm].each do |value|
          check_global_parameter(value)
        end
        
        @connection ||= RestClient::Resource.new(Chef::Config[:knife][:pve_cluster_url])
        @auth_params ||= begin
          token = nil
          csrf_prevention_token = nil
          @connection['access/ticket'].post :username=>Chef::Config[:knife][:pve_user_name],
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
    end # module
  end # class 
end # class