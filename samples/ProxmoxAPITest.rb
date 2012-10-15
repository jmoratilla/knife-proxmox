# Proxmox API Tests
# 
# Author: Jorge Juan Moratilla Porras
# 
# Description: some tests with the Proxmox VE API
#
#TODO: PUT

require 'rubygems'
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


puts 'GET'.blue

print ' list all users in the cluster: '.yellow
site['access/users'].get :CSRFPreventionToken => csrf_prevention_token, :cookie => token do |response, request, result, &block|
  puts "#{response.code}"
end

print ' list cluster resources: '.yellow
site['cluster/resources'].get :cookie => token do |response, request, result, &block|
  puts "#{response.code}"
end

print ' list available templates for download: '.yellow
site["nodes/#{nodename}/aplinfo"].get :CSRFPreventionToken => csrf_prevention_token, :cookie => token do |response, request, result, &block|
  puts "#{response.code}"
  puts "#{response}"
end

print ' list all VM\'s on a node: '.yellow
site["nodes/#{nodename}/openvz"].get :CSRFPreventionToken => csrf_prevention_token, :cookie => token do |response, request, result, &block|
  puts "#{response.code}"
end

puts 'POST'.blue

print ' create a new user: '.yellow
site['access/users'].post 'userid=test2@pve', :CSRFPreventionToken => csrf_prevention_token,:cookie => token do |response, request, result, &block|
  puts "#{response.code}"
end


print ' download a template: '.yellow
site["nodes/#{nodename}/aplinfo"].post "node=#{nodename},storage=local,template=ubuntu-10.04-turnkey-appengine_11.3-1_i386.tar.gz", :CSRFPreventionToken => csrf_prevention_token, :cookie => token do |response, request, result, &block|
  puts "#{response.code}"
end

print ' create an openvz VM: '.yellow
site["nodes/#{nodename}/openvz"].post "node=#{nodename},vmid=401,ostemplate=local:vztmpl/ubuntu-10.04-turnkey-appengine_11.3-1_i386.tar.gz", :CSRFPreventionToken=>csrf_prevention_token, :cookie=>token do |response, request, result, &block|
  puts "#{response.code}"
end


puts 'PUT'.blue

print ' modify one user: '.yellow
site['access/users/test@pve'].put 'comment=hello world', :CSRFPreventionToken => csrf_prevention_token, :cookie => token do |response, request, result, &block|
  puts "#{response.code}"
end

puts 'DELETE'.blue

print ' destroy an existing user: '.yellow
site['access/users/test2@pve'].delete :CSRFPreventionToken => csrf_prevention_token, :cookie => token do |response, request, result, &block|
  puts "#{response.code}"
end

print ' destroy an existing openvz VM: '.yellow
site["nodes/#{nodename}/openvz/401"].delete :CSRFPreventionToken => csrf_prevention_token, :cookie => token do |response, request, result, &block|
  puts "#{response.code}"
end
