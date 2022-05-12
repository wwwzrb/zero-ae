#!/bin/bash
num=$1

user=root
ip_array_pm=(20 21 22 25 26 31 32 33)
ip_prefix="192.168.10."

# Note! Install sshpass for all base images.
# Note! Need to add fingerprint in first login.

for(( i=0;i<${num};i++)) do
	ip=${ip_prefix}${ip_array_pm[i]}
	echo "$ip"
	# -e set password by environment variable $SSHPASS
	ssh ${user}@${ip} 'pwd' # add fingerprint in first login
    cat ~/.ssh/id_rsa.pub | sshpass -e ssh ${user}@${ip} 'cat >> .ssh/authorized_keys' # add local to remote
	# sshpass -e ssh ${user}@${ip} "cat ~/.ssh/id_rsa.pub | sshpass -e ssh ${user}@${rcv_ip} 'cat >> .ssh/authorized_keys'" # add remote to local
done

