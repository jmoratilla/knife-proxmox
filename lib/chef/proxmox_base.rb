=begin
 Usando fog, realizar la conexion contra proxmox y
 crear un conjunto de metodos para lalectura y escritura
 de la API
=end 

require 'chef/knife'

class Chef
  class Knife
    module ProxmoxBase
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
        #TODO: connection should export auth_param hash
      end
    end
  end
end