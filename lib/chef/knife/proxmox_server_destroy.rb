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
        :short => "-N NAME",
        :long => "--node-name NAME",
        :description => "The name of the node and client to delete, if it differs from the server name.  Only has meaning when used with the '--purge' option."
        
      option :vm_id,
        :long  => "--vmid number",
        :description => "The numeric identifier of the VM"

      def run
        # Needed
        connection
        
        #TODO: debe detectar que parametro se ha utilizado: nombre o vmid
        vm_id = nil
        
        if (config[:vm_id].nil? and config[:chef_node_name].empty?) then
          ui.error("You must use --vmid <id> or -N <Hostname>")
          exit 1
        elsif (!config[:chef_node_name].empty?)
            name = config[:chef_node_name]
            puts "node to destroy: #{name}"
            vm_id = name_to_vmid(name)
        else
          vm_id = config[:vm_id]
        end
        
        taskid=nil
        #TODO: Parar la maquina si esta arrancada.
        ui.msg("Stopping VM #{vm_id}....")
        @connection["nodes/#{Chef::Config[:knife][:pve_node_name]}/openvz/#{vm_id}/status/stop"].post "", @auth_params do |response, request, result, &block|
          ui.msg("Result: #{response.code}")
          # take the response and extract the taskid
          taskid = JSON.parse(response.body)['data']
        end
        
        #TODO: monitorizar la tarea para que cuando se crea la maquina, avisar al usuario
        taskstatus = nil
        while taskstatus.nil? do
          sleep(1)
          print "."
          @connection["nodes/#{Chef::Config[:knife][:pve_node_name]}/tasks/#{taskid}/status"].get @auth_params do |response, request, result, &block|
            taskstatus = JSON.parse(response.body)['data']['exitstatus']
          end
          puts taskstatus if !taskstatus.nil?
        end 
        
        @connection["nodes/#{Chef::Config[:knife][:pve_node_name]}/openvz/#{vm_id}"].delete @auth_params do |response, request, result, &block|
          ui.msg("Result: #{response.code}")
          # take the response and extract the taskid
          taskid = JSON.parse(response.body)['data']
        end
        
        #TODO: monitorizar la tarea para que cuando se crea la maquina, avisar al usuario
        taskstatus = nil
        while taskstatus.nil? do
          sleep(1)
          print "."
          @connection["nodes/#{Chef::Config[:knife][:pve_node_name]}/tasks/#{taskid}/status"].get @auth_params do |response, request, result, &block|
            taskstatus = JSON.parse(response.body)['data']['exitstatus']
          end
          puts taskstatus if !taskstatus.nil?
        end 
        

      end
      
      def name_to_vmid(name)
        @connection['cluster/resources?type=vm'].get @auth_params do |response, request, result, &block|
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