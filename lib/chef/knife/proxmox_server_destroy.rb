require 'chef/knife/proxmox_base'


class Chef
  class Knife
    class ProxmoxServerDestroy < Knife
      include Knife::ProxmoxBase

      banner "knife proxmox server destroy (options)"

      # Options for this action
      option :purge,
        :short => "-P",
        :long => "--purge",
        :boolean => true,
        :default => false,
        :description => "Destroy corresponding node and client on the Chef Server, in addition to destroying the Rackspace node itself. Assumes node and client have the same name as the server (if not, add the '--node-name' option)."

      option :chef_node_name,
        :short => "-H hostname",
        :long => "--hostname hostname",
        :description => "The name of the node and client to delete, if it differs from the server name.  Only has meaning when used with the '--purge' option."
        
      option :vm_id,
        :short => "-I number",
        :long  => "--vmid number",
        :description => "The numeric identifier of the VM"

      def run
        # Needed
        connection
        
        #TODO: must detect which parameter has been used: name or vmid
        vm_id = nil
        
        if (config[:vm_id].nil? and config[:chef_node_name].nil?) then
          ui.error("You must use -I <id> or -H <Hostname>")
          exit 1
        elsif (!config[:chef_node_name].nil?)
            name = config[:chef_node_name]
            puts "node to destroy: #{name}"
            vm_id = server_name_to_vmid(name)
        else
          vm_id = config[:vm_id]
        end
        
        server_stop(vm_id)
        
        @connection["nodes/#{Chef::Config[:knife][:pve_node_name]}/openvz/#{vm_id}"].delete @auth_params do |response, request, result, &block|
          action_response("server destroy",response)
        end
        
      end
      
    end
  end
end