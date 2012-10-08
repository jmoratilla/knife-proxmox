require 'chef/knife/proxmox_base'

class Chef
  class Knife
    class ProxmoxTemplateList < Knife

      include Knife::ProxmoxBase

      banner "knife proxmox template list (options)"
      
      def run
        template_list = [
          ui.color('Name', :bold),
          ui.color('Disk', :bold)
        ]
        
        # Como saco este dato?
        # pvesh get /nodes/SERVER_NAME/storage/STORAGE/content
        # pvesh ls /nodes/SERVER_NAME/storage/STORAGE/content
        # pvesm list local -content vztmpl
        
        
        puts ui.list(template_list, :uneven_columns_across, 5)
      end
    end
  end
end