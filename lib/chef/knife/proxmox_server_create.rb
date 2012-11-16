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
        
      option :vm_ipaddress,
        :long  => "--ipaddress IP Address",
        :description => "force guest to use venet interface with this ip address"

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
        vm_ipaddress= config[:vm_ipaddress]|| nil
        vm_netif    = config[:vm_netif]    || 'ifname%3Deth0%2Cbridge%3Dvmbr0'
        vm_template = template_number_to_name(config[:vm_template],vm_storage) || 'local%3Avztmpl%2Fubuntu-11.10-x86_64-jorge2-.tar.gz'
        
        vm_definition = "vmid=#{vm_id}&hostname=#{vm_hostname}&storage=#{vm_storage}&password=#{vm_password}&ostemplate=#{vm_template}&memory=#{vm_memory}&swap=#{vm_swap}&disk=#{vm_disk}&cpus=#{vm_cpus}"
        
        # Add ip_address parameter to vm_definition if it's provided by CLI
        if (config[:vm_ipaddress]) then 
          vm_definition += "&ip_address=" + vm_ipaddress
        elsif (config[:vm_netif] || vm_netif) then
          vm_definition += "&netif=" + vm_netif
        end
        
        Chef::Log.debug(vm_definition)
        
        taskid = nil
        
        @connection["nodes/#{Chef::Config[:knife][:pve_node_name]}/openvz"].post "#{vm_definition}", @auth_params do |response, request, result, &block|
          ui.msg("Result: #{response.code}")
          
          # take the response and extract the taskid
          taskid = JSON.parse(response.body)['data'] 
        end
        
        waitfor(taskid)
        
        # TODO: It's possible to use an action defined in another class? Ex: ProxmoxServerStart.run()?
        ui.msg("Starting VM #{vm_id}....")
        @connection["nodes/#{Chef::Config[:knife][:pve_node_name]}/openvz/#{vm_id}/status/start"].post "", @auth_params do |response, request, result, &block|
          ui.msg("Result: #{response.code}")
          # take the response and extract the taskid
          taskid = JSON.parse(response.body)['data']
        end
        
        waitfor(taskid)
        
        #TODO: deberia poder conectar a la maquina y obtener su ip, asi seria todo mas facil
      end

    end
  end
end