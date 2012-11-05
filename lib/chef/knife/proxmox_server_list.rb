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
          ui.color('Name', :bold),
          ui.color('Type', :bold),
          ui.color('Status',:bold)
        ]
        @connection['cluster/resources?type=vm'].get @auth_params do |response, request, result, &block|
          JSON.parse(response.body)['data'].each {|entry|
            server_list << entry['vmid'].to_s
            server_list << entry['name']
            server_list << entry['type']
            status = (entry['uptime'] == 0)?'down':'up'
            server_list << status
          }
        end
        puts ui.list(server_list, :uneven_columns_across, 4)
      end
    end
  end
end