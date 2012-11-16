require 'chef/knife/proxmox_base'


class Chef
  class Knife
    class ProxmoxServerStart < Knife

      include Knife::ProxmoxBase

      banner "knife proxmox server start (options)"

      option :vm_id,
        :long  => "--vmid number",
        :description => "The numeric identifier of the VM"

      def run
        # Needed
        connection
        vm_id = nil
        check_config_parameter(:vm_id)
        
        vm_id = config[:vm_id]
        ui.msg("Starting VM #{vm_id}....")
        @connection["nodes/#{Chef::Config[:knife][:pve_node_name]}/openvz/#{vm_id}/status/start"].post "", @auth_params do |response, request, result, &block|
          ui.msg("Result: #{response.code}")
        end
      end
    end
  end
end