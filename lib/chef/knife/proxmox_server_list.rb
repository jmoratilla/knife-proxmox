require 'chef/knife/proxmox_base'


class Chef
  class Knife
    class ProxmoxServerList < Knife

      include Knife::ProxmoxBase

      banner "knife proxmox server list (options)"

      def run
        # Needed
        connection
        
        server_list = [
          ui.color('Id'  , :bold),
          ui.color('Node', :bold),
          ui.color('Name', :bold),
          ui.color('Type', :bold),
          ui.color('Status',:bold),
          ui.color('IP Address',:bold)

        ]
        @connection['cluster/resources?type=vm'].get @auth_params do |response, request, result, &block|
          JSON.parse(response.body)['data'].each {|entry|
            vm_id = entry['vmid']
            type  = entry['type']
            server_list << vm_id.to_s
            server_list << entry['node']
            server_list << entry['name']
            server_list << type
            status = (entry['uptime'] == 0)?'down':'up'
            server_list << status
            ipaddress = (type.to_s.match('openvz'))?server_get_data(vm_id,'ip'):"Not Available"
            server_list << ipaddress
          }
        end
        puts ui.list(server_list, :uneven_columns_across, 6)
      end
    end
  end
end