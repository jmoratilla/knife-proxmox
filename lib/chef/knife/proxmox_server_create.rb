require 'chef/knife/proxmox_base'

class Chef
  class Knife
    class ProxmoxServerCreate < Knife
      
      include Knife::ProxmoxBase
      
      banner "knife proxmox server create (options)"
      
      # TODO: parameters for openvz should be in other object
      option :vm_hostname,
        :short => "-N hostname",
        :description => "VM instance hostname"
      
      option :vm_cpus,
        :long  => "--cpus number",
        :description => "Number of cpus of the VM instance"
        
      option :vm_memory,
        :long  => "--mem MB",
        :description => "Memory in MB"
        
      option :vm_swap,
        :long  => "--swap MB",
        :description => "Memory in MB for swap"
        
      option :vm_vmid,
        :long  => "--vmid id",
        :description => "Id for the VM"
        
      option :vm_disk,
        :long  => "--disk GB",
        :description => "Disk space in GB"
        
      option :vm_storage,
        :long  => "--storage name",
        :description => "Name of the storage where to reserve space"
        
      option :vm_password,
        :long  => "--vm_pass password",
        :description => "root password for VM (openvz only)"
        
      option :vm_netif,
        :long  => "--netif netif_specification",
        :description => "description of the network interface (experimental)"
        
      option :vm_template,
        :long  => "--template number",
        :description => "id of the template"

      def run
        # Needed
        connection
        
        vm_id       = config[:vm_vmid]     || new_vmid
        vm_hostname = config[:vm_hostname] || 'proxmox'
        vm_storage  = config[:vm_storage]  || 'local'
        vm_password = config[:vm_password] || 'pve123'
        vm_cpus     = config[:vm_cpus]     || 1
        vm_memory   = config[:vm_memory]   || 512
        vm_disk     = config[:vm_disk]     || 4
        vm_swap     = config[:vm_swap]     || 512
        vm_netif    = config[:vm_netif]    || 'ifname%3Deth0%2Cbridge%3Dvmbr0'
        vm_template = template_number_to_name(config[:vm_template],vm_storage) || 'local%3Avztmpl%2Fubuntu-11.10-x86_64-jorge2-.tar.gz'
        
        vm_definition = "vmid=#{vm_id}&hostname=#{vm_hostname}&storage=#{vm_storage}&password=#{vm_password}&ostemplate=#{vm_template}&memory=#{vm_memory}&swap=#{vm_swap}&disk=#{vm_disk}&cpus=#{vm_cpus}&netif=#{vm_netif}"
        Chef::Log.debug(vm_definition)
        
        @connection["nodes/#{Chef::Config[:knife][:pve_node_name]}/openvz"].post "#{vm_definition}", @auth_params do |response, request, result, &block|
          ui.msg("Result: #{response.code}")
        end
        
        #TODO: monitorizar la tarea para que cuando se crea la maquina, avisar al usuario
        (1..30).each do
          print '.'
          sleep 1
        end
        puts ""
        
        ui.msg("Starting VM #{vm_id}....")
        @connection["nodes/#{Chef::Config[:knife][:pve_node_name]}/openvz/#{vm_id}/status/start"].post "", @auth_params do |response, request, result, &block|
          ui.msg("Result: #{response.code}")
        end
        
        #TODO: deberia poder conectar a la maquina y obtener su ip, asi seria todo mas facil
      end
      
      # TODO: waitfor end of the task, need the taskid and the timeout
      def waitfor(taskid,timeout=30)
        timeout.times {
          @connection["cluster/tasks"].get "", @auth_params do |response, request, result, &block|
            ui.msg("Result: #{response.code}")
          end
        }
      end
      
      def new_vmid
        vmid ||= @connection['cluster/resources?type=vm'].get @auth_params do |response, request, result, &block|
          data = JSON.parse(response.body)['data']
          vmids = Set[]
          data.each {|entry|
            vmids.add entry['vmid']
          }
          vmids.max + 1
        end
      end
      
      
      def template_number_to_name(number,storage)
        template_list = []
        #TODO: esta parte hay que sacarla a un modulo comun de acceso a templates
        @connection["nodes/#{Chef::Config[:knife][:pve_node_name]}/storage/#{storage}/content"].get @auth_params do |response, request, result, &block|
          JSON.parse(response.body)['data'].each { |entry|
            if entry['content'] == 'vztmpl' then
              template_list << entry['volid']
            end
          }
        end
        return CGI.escape(template_list[number.to_i])
      end
      
    end
  end
end