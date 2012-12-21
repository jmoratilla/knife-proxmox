# Proxmox API Tests
# 
# Author: Jorge Juan Moratilla Porras
# 
# Description: some tests with the Proxmox VE API


#require 'rubygems'
require 'rest_client'
require 'json'
require 'pp'
require 'colorize'

# Default values
@username = ENV['PVE_USER_NAME'] || 'test'
@realm    = ENV['PVE_REALM'] || 'pve'
@password = ENV['PVE_USER_PASSWORD'] || 'test123'
@url_base = ENV['PVE_CLUSTER_URL'] || 'https://localhost:8006/api2/json/'
@nodename = ENV['PVE_NODE_NAME'] || 'localhost'
@storagename = ENV['PVE_STORAGE_NAME'] || 'local'

csrf_prevention_token = nil
token = nil

# RestClient logger
log = RestClient.log = []

puts "
SERVER INFO: 
  PVE_CLUSTER_URL  => #{@url_base}
  PVE_NODE_NAME    => #{@nodename}
  PVE_USER_NAME    => #{@username}
  PVE_REALM        => #{@realm}
  PVE_STORAGE_NAME => #{@storagename}
"

@site = RestClient::Resource.new(@url_base)

puts 'AUTH'.blue

print ' To request access: '.yellow
@site['access/ticket'].post :username=>@username,:realm=>@realm,:password=>@password do |response, request, result, &block| 
  if response.code == 200 then
    data = JSON.parse(response.body)
    ticket = data['data']['ticket']
    csrf_prevention_token = data['data']['CSRFPreventionToken']
    if !ticket.nil? then
# Token is a cookie coded like this one
# 'PVEAuthCookie=PVE%3Atest@pve%3A5079E676%3A%3AE5Btg[...]crcp/RzEitO/vKMvr5YpAmjBRw7HS2IA3Q%3D%3D'
      token = 'PVEAuthCookie=' + ticket.gsub!(/:/,'%3A').gsub!(/=/,'%3D')
    end
  end
  puts "#{response.code}" 
end 

@auth_params = {
  :CSRFPreventionToken => csrf_prevention_token,
  :cookie => token
}

puts 'GET'.blue

# server_get_address: Returns the IP Address of the machine to chef
def server_get_address(vmid)
  @site["nodes/#{@nodename}/openvz/#{vmid}/status/current"].get @auth_params do |response, request, result, &block|
    data = JSON.parse(response.body)['data']
    pp data
  end
end

puts 'Get IP Address: '
server_get_address(201)


=begin
print ' list VMs: '.yellow
site['cluster/resources?type=vm'].get auth_params do |response, request, result, &block|
  puts "#{response.code}"
  data = JSON.parse(response.body)['data']
  data.each {|entry|
    puts "#{entry['name']}:"
    entry.keys.sort.each {|key|
      puts "\t#{key}: #{entry[key]}" unless key == 'name'
      
    }
  }
end

print ' list Nodes: '.yellow
site['cluster/resources?type=node'].get auth_params do |response, request, result, &block|
  puts "#{response.code}"
  data = JSON.parse(response.body)['data']
  data.each {|entry|
    puts "#{entry['node']}:"
    entry.keys.sort.each {|key|
      puts "\t#{key}: #{entry[key]}" unless key == 'node'
    }
  }
end
=end
