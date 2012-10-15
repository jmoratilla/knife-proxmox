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
username = ENV['PVE_USERNAME'] || 'test'
realm    = ENV['PVE_REALM'] || 'pve'
password = ENV['PVE_USER_PASSWORD'] || 'test123'
url_base = ENV['PVE_CLUSTER_URL'] || 'https://localhost:8006/api2/json/'
csrf_prevention_token = nil
token = nil

# RestClient logger
log = RestClient.log = []

site = RestClient::Resource.new(url_base)

puts 'AUTH'.blue

print 'To request access: '.yellow
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

print 'To list cluster resources: '.yellow
site['cluster/resources'].get :cookie => token do |response, request, result, &block|
  puts "#{response.code}"
end

print 'To list available templates for download: '.yellow
site['nodes/ankh/aplinfo'].get :CSRFPreventionToken => csrf_prevention_token, :cookie => token do |response, request, result, &block|
  puts "#{response.code}"
end

print 'To list all VM\'s on a node: '.yellow
site['nodes/ankh/openvz'].get :CSRFPreventionToken => csrf_prevention_token, :cookie => token do |response, request, result, &block|
  puts "#{response.code}"
end

puts 'POST'.blue

print 'To download a template: '.yellow
site['nodes/ankh/aplinfo'].post :CSRFPreventionToken => csrf_prevention_token, :cookie => token, :node => 'ankh', :storage => 'local', :template => 'ubuntu-10.04-turnkey-appengine_11.3-1_i386.tar.gz' do |response, request, result, &block|
  puts "#{response.code}"
end

print 'To create an openvz VM: '.yellow
site['nodes/ankh/openvz?node=ankh&vmid=401&ostemplate=local%3Avztmpl%2Fubuntu-11.10-x86_64-jorge2-.tar.gz'].post :CSRFPreventionToken=>csrf_prevention_token, :cookie=>token do |response, request, result, &block|
  puts "#{response.code}"
end

puts 'DELETE'.blue
print 'To destroy an existing openvz VM: '.yellow
site['nodes/ankh/openvz/401'].delete :CSRFPreventionToken => csrf_prevention_token, :cookie => token do |response, request, result, &block|
  puts "#{response.code}"
end

#pp log
