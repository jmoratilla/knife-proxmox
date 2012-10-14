require 'rubygems'
require 'rest_client'
require 'json'
require 'pp'
require 'base64'

# Sacar las variables a variables de entorno
username = ENV['PVE_USERNAME'] || 'test'
realm    = ENV['PVE_REALM'] || 'pve'
password = ENV['PVE_USER_PASSWORD'] || 'test123'
url_auth = ENV['PVE_CLUSTER_URL'] || 'https://localhost:8006/api2/json/access/ticket'

# Autenticacion

response_auth = RestClient.post url_auth,{:username=>username,:realm => realm, :password=>password}
data = JSON.parse(response_auth.body)
ticket = data['data']['ticket']
csrf_prevention_token = data['data']['CSRFPreventionToken']

# Codificacion del ticket para convertirlo en algo como esto:
# 'PVEAuthCookie=PVE%3Atest@pve%3A5079E676%3A%3AE5BtOz0UhhAWDKVSxPBpegcrcp/RzEdg4Q9oI9YmBvrycGD6st3iE6uTWAMviX2cDq5OlezVYgjtE8/v5EtjgblNjfT2jtCoNqZtpIyV/pKhwfqFw5S2bjYJH52jSlnbxvlDgc7cciX7lSTHvrZOpc0trKmElYWWfb68po6wV4obgckECBxFo0Gmh//DbM2dyAdtlSS23opZIg3gYgb3A7+rmE8v2injbAvqicGuF5ard9o1pRbkE4SW5RB8wJLquGYu7htAkpRgWKZCpBsArk+cLXp1Uq0+1PRm5Ufp4lN6hVkCgLMjWcPNy4pkitO/vKMvr5YpAmjBRw7HS2IA3Q%3D%3D'
token = 'PVEAuthCookie=' + ticket.gsub!(/:/,'%3A').gsub!(/=/,'%3D')

# Acceso a la API: GET
url_status = 'https://localhost:8006/api2/json/cluster/resources'
response_status = RestClient.get(
  url_status,
  {
    :CSRFPreventionToken => csrf_prevention_token,
    :cookie => token
  }
) { |response, request, result, &block|
  case response.code
  when 200
    p "It worked !"
    response.body
  when 401
    p "Error de Autenticacion"
  else
    response.return!(request, result, &block)
  end
}

#TODO: Acceso a la API: POST

#TODO: Acceso a la API: PUT

#TODO: Acceso a la API: DELETE

