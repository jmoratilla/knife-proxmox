require 'chef/knife/proxmox_base'

class Chef
  class Knife
    class ProxmoxServerModify < Knife
      
      include Knife::ProxmoxBase
      
      banner "knife proxmox server modify (options)"
      
      # TODO: parameters for openvz should be in other object
      option :vm_hostname,
        :short => "-H hostname",
        :long  => "--hostname hostname",
        :description => "VM instance hostname"

      option :vm_cpus,
        :short => "-C CPUs",
        :long  => "--cpus number",
        :description => "Number of cpus of the VM instance"

      option :vm_memory,
        :short => "-M MB",
        :long  => "--mem MB",
        :description => "Memory in MB"

      option :vm_swap,
        :short => "-SW",
        :long  => "--swap MB",
        :description => "Memory in MB for swap"

      option :vm_vmid,
        :short => "-I id",
        :long  => "--vmid id",
        :description => "Id for the VM"

      option :vm_disk,
        :short => "-D disk",
        :long  => "--disk GB",
        :description => "Disk space in GB"

      def run
        # Needed
        connection
        
        vm_config = Hash.new

        vm_config[:id]       = config[:vm_vmid]     || nil
        vm_config[:hostname] = config[:vm_hostname] || nil
        vm_config[:cpus]     = config[:vm_cpus]     || nil #server_get_data(vm_id,"cpus")
        vm_config[:memory]   = config[:vm_memory]   || nil #server_get_data(vm_id,"memory")
        vm_config[:disk]     = config[:vm_disk]     || nil #server_get_data(vm_id,"disk")
        vm_config[:swap]     = config[:vm_swap]     || nil #server_get_data(vm_id,"swap")
        
        #vm_definition = "memory=#{vm_memory}&swap=#{vm_swap}&disk=#{vm_disk}&cpus=#{vm_cpus}"
        #vm_definition = "cpus=#{vm_cpus.to_i}&memory=#{'1024'.to_i}"
        vm_mod_op = vm_config.keys.select { |v| vm_config[v] }
        vm_definition = ""
        vm_mod_op.each do |k|
          vm_definition << k.to_s << "=" << vm_config[k].to_s
        end
        puts vm_definition
        
        Chef::Log.debug(vm_definition)
        
        server_modify(vm_id,vm_definition)
        
      end

    end
  end
end
