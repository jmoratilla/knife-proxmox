#require 'chef/knife/proxmox_base'
require 'rubygems'
require 'rest_client'
require 'json'
require 'cgi'

class Chef
  class Knife
    class ProxmoxServerCreate < Knife

      banner "knife proxmox server create (options)"
      
      site = nil
      auth_params = nil
      
          deps do
            require 'rubygems'
            require 'rest_client'
            require 'json'
            require 'cgi'
          end

          option :pve_cluster_url,
            :short => "-U URL",
            :long  => "--pve_cluster_url URL",
            :description => "Your URL to access Proxmox VE server/cluster",
            :proc  => Proc.new {|url| Chef::Config[:knife][:pve_cluster_url] = url }

          option :pve_user_name,
            :short => "-u username",
            :long  => "--username username",
            :description => "Your username in Proxmox VE",
            :proc  => Proc.new {|username| Chef::Config[:knife][:pve_user_name] = username }

          option :pve_user_password,
            :short => "-p password",
            :long  => "--password password",
            :description => "Your password in Proxmox VE",
            :proc  => Proc.new {|password| Chef::Config[:knife][:pve_user_password] = password }

          option :pve_user_realm,
            :short => "-R realm",
            :long  => "--realm realm",
            :description => "Your realm of Authentication in Proxmox VE",
            :proc  => Proc.new {|realm| Chef::Config[:knife][:pve_user_realm] = realm }

          option :pve_node_name,
            :short => "-n node",
            :long  => "--node nodename",
            :description => "Proxmox VE server name where you will actuate",
            :proc  => Proc.new {|node| Chef::Config[:knife][:pve_node_name] = node }
          
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
        site = RestClient::Resource.new(Chef::Config[:knife][:pve_cluster_url])
        token = nil
        csrf_prevention_token = nil
        site['access/ticket'].post :username=>Chef::Config[:knife][:pve_user_name],
          :realm=>Chef::Config[:knife][:pve_user_realm],
          :password=>Chef::Config[:knife][:pve_user_password] do |response, request, result, &block|
            if response.code == 200 then
              data = JSON.parse(response.body)
              ticket = data['data']['ticket']
              csrf_prevention_token = data['data']['CSRFPreventionToken']
              if !ticket.nil? then
                # Token is a cookie coded like this one
                # 'PVEAuthCookie=PVE%3Atest@pve%3A5079E676%3A%3AE5Btg[...]crcp/RzEitO/vKMvr5YpAmjBRw7HS2IA3Q%3D%3D'
                # TODO: change ticket.gsub for CGI.escape(str)
                token = 'PVEAuthCookie=' + ticket.gsub!(/:/,'%3A').gsub!(/=/,'%3D')
              end
            end
        end
        auth_params = {:CSRFPreventionToken => csrf_prevention_token, :cookie => token}

        vm_id       = config[:vm_vmid]     || new_vmid(site,auth_params)
        vm_hostname = config[:vm_hostname] || 'proxmox'
        vm_storage  = config[:vm_storage]  || 'local'
        vm_password = config[:vm_password] || 'pve123'
        vm_cpus     = config[:vm_cpus]     || 1
        vm_memory   = config[:vm_memory]   || 512
        vm_disk     = config[:vm_disk]     || 4
        vm_swap     = config[:vm_swap]     || 512
        vm_netif    = config[:vm_netif]    || 'ifname%3Deth0%2Cbridge%3Dvmbr0'
        vm_template = template_number_to_name(site,auth_params,config[:vm_template],vm_storage) || 'local%3Avztmpl%2Fubuntu-11.10-x86_64-jorge2-.tar.gz'
        
        vm_definition = "vmid=#{vm_id}&hostname=#{vm_hostname}&storage=#{vm_storage}&password=#{vm_password}&ostemplate=#{vm_template}&memory=#{vm_memory}&swap=#{vm_swap}&disk=#{vm_disk}&cpus=#{vm_cpus}&netif=#{vm_netif}"
        ui.msg vm_definition
        
        site["nodes/#{Chef::Config[:knife][:pve_node_name]}/openvz"].post "#{vm_definition}", auth_params do |response, request, result, &block|
          ui.msg("Result: #{response.code}")
        end

      end
      
      def new_vmid(connection,auth)
        vmid ||= connection['cluster/resources?type=vm'].get auth do |response, request, result, &block|
          data = JSON.parse(response.body)['data']
          vmids = Set[]
          data.each {|entry|
            vmids.add entry['vmid']
          }
          vmids.max + 1
        end
      end
      
      #TODO: la salida debe estar codificada al estilo 
      # 'local%3Avztmpl%2Fubuntu-11.10-x86_64-jorge2-.tar.gz'
      
      def template_number_to_name(connection,auth,number,storage)
        template_list = []
        #TODO: esta parte hay que sacarla a un modulo comun de acceso a templates
        connection["nodes/#{Chef::Config[:knife][:pve_node_name]}/storage/#{storage}/content"].get auth do |response, request, result, &block|
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