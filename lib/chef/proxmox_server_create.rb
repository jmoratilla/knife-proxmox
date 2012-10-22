#require 'chef/knife/proxmox_base'
require 'rubygems'
require 'rest_client'
require 'json'

class Chef
  class Knife
    class ProxmoxServerCreate < Knife

      banner "knife proxmox server create (options)"
      
      site = nil
      auth_params = nil
      
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
          
          # TODO: parameters for openvz should be in other object
          option :openvz_hostname,
            :short => "-N hostname",
            :description => "OpenVZ hostname",
            :proc  => Proc.new {|hostname| }

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


        # FIXME: vmid hay que conseguir obtener el siguiente disponible
        # FIXME: storagename debe ser automatico
        # FIXME: template debe ser accesible a traves de parametros
        # FIXME: memoria, swap, cpus, disk, hostname, password, netif deben ser configurados a traves de parametros
        site["nodes/#{Chef::Config[:knife][:pve_node_name]}/openvz"].post 'vmid=401&hostname=melon1&storage=local&password=melon123&ostemplate=local%3Avztmpl%2Fubuntu-11.10-x86_64-jorge2-.tar.gz&memory=512&swap=512&disk=4&cpus=1&netif=ifname%3Deth0%2Cbridge%3Dvmbr0', auth_params do |response, request, result, &block|
          ui.msg("Result: #{response.code}")
        end

      end
    end
  end
end