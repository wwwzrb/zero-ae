#!/bin/bash
host_num=${1}

folder_name=zero-multi

user=root
ip_prefix="192.168.10."
ip_array_pm=(20 21 22 25 26 31 32 33)

path_prefix=~/zero-ae
folder_name=zero-scalability

local_path=${path_prefix}
remote_path=${path_prefix}
     
for(( i=0;i<${host_num};i++)) do
	ip=${ip_prefix}${ip_array_pm[i]}
	echo "$ip"
    sshpass ssh ${user}@$ip "cd ${remote_path}/${folder_name}/script/multiqp-zero; sh -x zero-clean.sh" 
	sshpass ssh ${user}@${ip} "rm -rf ${remote_path}" # clean folder if needed
done
