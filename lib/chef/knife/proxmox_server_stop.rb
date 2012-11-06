require 'chef/knife/proxmox_base'


class Chef
  class Knife
    class ProxmoxServerStop < Knife

      include Knife::ProxmoxBase

      banner "knife proxmox server start (options)"

      option :vm_id,
        :long  => "--vmid number",
        :description => "The numeric identifier of the VM"

      def run
        # Needed
        connection
        vm_id = nil
        
        vm_id = config[:vm_id]
        ui.msg("Stoping VM #{vm_id}....")
        @connection["nodes/#{Chef::Config[:knife][:pve_node_name]}/openvz/#{vm_id}/status/stop"].post "", @auth_params do |response, request, result, &block|
          ui.msg("Result: #{response.code}")
        end
      end
    end
  end
end