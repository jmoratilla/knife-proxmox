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
username = ENV['PVE_USER_NAME'] || 'test'
realm    = ENV['PVE_REALM'] || 'pve'
password = ENV['PVE_USER_PASSWORD'] || 'test123'
url_base = ENV['PVE_CLUSTER_URL'] || 'https://localhost:8006/'
nodename = ENV['PVE_NODE_NAME'] || 'localhost'
storagename = ENV['PVE_STORAGE_NAME'] || 'local'
url_base += 'api2/json/'

csrf_prevention_token = nil
token = nil

# RestClient logger
log = RestClient.log = []

puts "
SERVER INFO: 
  PVE_CLUSTER_URL  => #{url_base}
  PVE_NODE_NAME    => #{nodename}
  PVE_USER_NAME    => #{username}
  PVE_REALM        => #{realm}
  PVE_STORAGE_NAME => #{storagename}
"

site = RestClient::Resource.new(url_base)

puts 'AUTH'.blue

print ' To request access: '.yellow
site['access/ticket'].post :username=>username,:realm=>realm,:password=>password do |response, request, result, &block| 
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

auth_params = {
  :CSRFPreventionToken => csrf_prevention_token,
  :cookie => token
}

puts 'GET'.blue

print ' list all users in the cluster: '.yellow
site['access/users'].get auth_params do |response, request, result, &block|
  puts "#{response.code}"
end

print ' list cluster resources: '.yellow
site['cluster/resources?type=vm'].get auth_params do |response, request, result, &block|
  puts "#{response.code}"
  data = JSON.parse(response.body)['data']
  data.each {|entry|
    puts "vmid: #{entry['vmid']}, host: #{entry['name']}, type: #{entry['type']}" #if entry['type'] == 'openvz' or entry['type'] == 'qemu'
  }
end

print ' list available templates for download: '.yellow
site["nodes/#{nodename}/aplinfo"].get auth_params do |response, request, result, &block|
  puts "#{response.code}"
  data = JSON.parse(response.body)['data']
  data.each { |entry|
    puts "#{entry['template']}: #{entry['os']}"
  }
end

print ' list all installed templates on a specific node: '.yellow
site["nodes/#{nodename}/storage/#{storagename}/content"].get auth_params do |response, request, result, &block|
  puts "#{response.code}"
  data = JSON.parse(response.body)['data']
  data.each {|entry|
    puts "#{entry['volid']}: #{entry['size']}" if entry['content'] == 'vztmpl'
  }
end


print ' list all VM\'s per node: '.yellow
site["nodes/#{nodename}/openvz"].get auth_params do |response, request, result, &block|
  puts "#{response.code}"
  data = JSON.parse(response.body)['data']
  puts "#{nodename}:"
  data.each {|entry|
    puts "\t#{entry['vmid']}: #{entry['name']}"
  }
end


print ' list all tasks in the cluster: '.yellow
site["cluster/tasks"].get auth_params do |response, request, result, &block|
  puts "#{response.code}" 
end

puts 'POST'.blue

print ' create a new user: '.yellow
site['access/users'].post 'userid=test2@pve', auth_params do |response, request, result, &block|
  puts "#{response.code}"
end

taskid = nil

print ' download a template: '.yellow
site["nodes/#{nodename}/aplinfo"].post "storage=local&template=ubuntu-10.04-turnkey-appengine_11.3-1_i386.tar.gz", auth_params do |response, request, result, &block|
  puts "#{response.code}"
  taskid = JSON.parse(response.body)['data'] # For last test (stop a running task)
end

print ' create an openvz VM: '.yellow
site["nodes/#{nodename}/openvz"].post 'vmid=401&hostname=melon1&storage=local&password=melon123&ostemplate=local%3Avztmpl%2Fubuntu-11.10-x86_64-jorge2-.tar.gz&memory=512&swap=512&disk=4&cpus=1&netif=ifname%3Deth0%2Cbridge%3Dvmbr0', auth_params do |response, request, result, &block|
  puts "#{response.code}"
end

print ' create an openvz VM without vmid: '.yellow
site["nodes/#{nodename}/openvz"].post 'hostname=melon2&storage=local&password=melon123&ostemplate=local%3Avztmpl%2Fubuntu-11.10-x86_64-jorge2-.tar.gz&memory=512&swap=512&disk=4&cpus=1&netif=ifname%3Deth0%2Cbridge%3Dvmbr0', auth_params do |response, request, result, &block|
  puts "#{response.code}"
end

puts 'PUT'.blue

print ' modify one user: '.yellow
site['access/users/test@pve'].put 'comment=hello world', auth_params do |response, request, result, &block|
  puts "#{response.code}"
end

puts "Sleeping 10 secs before deleting stuff"
sleep 10

puts 'DELETE'.blue

print ' destroy an existing user: '.yellow
site['access/users/test2@pve'].delete auth_params do |response, request, result, &block|
  puts "#{response.code}"
end

print ' destroy an existing openvz VM: '.yellow
site["nodes/#{nodename}/openvz/401"].delete auth_params do |response, request, result, &block|
  puts "#{response.code}"
end

print ' stop a running task: '.yellow
site["nodes/#{nodename}/tasks/#{taskid}"].delete auth_params do |response, request, result, &block|
  puts "#{response.code}"
end
