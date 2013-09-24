#!/bin/bash

# default variables
defserver="localhost"
defnode="localhost"
defrealm="pam"
defuser="root"
defpass="proxmox"


echo "This script will help you to setup your knife-proxmox environment"
echo "variables. Answer the questions and it will show the vars."
until [ "$answer" = "Y" ] || [ "$answer" = "y" ]
do
  echo
  echo -n "Proxmox server IP or FQDN [$defserver]: "
  read server
  echo -n "Proxmox node name [$defnode]: "
  read node
  echo -n "Proxmox realm [$defrealm]: "
  read realm
  echo -n "Proxmox user name [$defuser]: "
  read user
  echo -n "Proxmox user password [$defpass]: "
  read pass
  echo
  echo -n "Are you sure? (Y/N)? " 
  read answer
done

: ${server:="$defserver"}
: ${node:="$defnode"}
: ${realm:="$defrealm"}
: ${user:="$defuser"}
: ${pass:="$defpass"}

echo "This is the setup:"
echo
echo "export PVE_NODE_NAME=$node"
echo "export PVE_USER_REALM=$realm"
echo "export PVE_CLUSTER_URL=https://$server:8006/api2/json/"
echo "export PVE_USER_NAME=$user"
echo "export PVE_USER_PASSWORD=$pass"
echo

echo "Now, you can save this variables to your profile and use it later."
echo "Well done. Good bye."
exit 0
