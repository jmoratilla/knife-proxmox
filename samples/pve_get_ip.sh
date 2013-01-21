#!/bin/sh



NEW_IP=""
while [ "x${NEW_IP}" = "x" ]; do
  NEW_IP=$(${SSHCMD} vzctl exec ${NEW_CTID} ip addr ls dev eth0 | awk '/inet / {gsub(/\/24/, "", $2); print $2}')
  sleep 1
done
