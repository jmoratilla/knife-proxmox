#require 'chef/knife/proxmox_base'
require 'chef/node'
require 'chef/api_client'

class Chef
  class Knife
    class ProxmoxServerDestroy < Knife

      banner "knife proxmox server destroy (options)"

# Generic options
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

# Options for this action
      option :purge,
        :short => "-P",
        :long => "--purge",
        :boolean => true,
        :default => false,
        :description => "Destroy corresponding node and client on the Chef Server, in addition to destroying the Rackspace node itself. Assumes node and client have the same name as the server (if not, add the '--node-name' option)."

      option :chef_node_name,
        :short => "-N NAME",
        :long => "--node-name NAME",
        :description => "The name of the node and client to delete, if it differs from the server name.  Only has meaning when used with the '--purge' option."


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

        name = config[:chef_node_name]
        puts "node to destroy: #{name}"
        server_vmid = name_to_vmid(site,auth_params,name)
        site["nodes/#{Chef::Config[:knife][:pve_node_name]}/openvz/#{server_vmid}"].delete auth_params do |response, request, result, &block|
          ui.msg("Result: #{response.code}")
        end

      end
      
      def name_to_vmid(connection,auth,name)
        connection['cluster/resources?type=vm'].get auth do |response, request, result, &block|
          data = JSON.parse(response.body)['data']
          data.each {|entry|
            return entry['vmid'] if entry['name'].to_s.match(name)
          }
        end
      end
      
      
      
      # Extracted from Chef::Knife.delete_object, because it has a
      # confirmation step built in... By specifying the '--purge'
      # flag (and also explicitly confirming the server destruction!)
      # the user is already making their intent known.  It is not
      # necessary to make them confirm two more times.
      def destroy_item(klass, name, type_name)
        begin
          object = klass.load(name)
          object.destroy
          ui.warn("Deleted #{type_name} #{name}")
        rescue Net::HTTPServerException
          ui.warn("Could not find a #{type_name} named #{name} to delete!")
        end
      end      
    end
  end
end