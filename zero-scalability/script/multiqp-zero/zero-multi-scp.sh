#!/bin/bash
num=$1

user=root
ip_prefix="192.168.10."
ip_array_pm=(20 21 22 25 26 31 32 33)

path_prefix=~/zero-ae
folder_name=zero-scalability

local_path=${path_prefix}
remote_path=${path_prefix}

for(( i=0;i<${num};i++)) do
	ip=${ip_prefix}${ip_array_pm[i]}
	echo "$ip"
	sshpass ssh ${user}@${ip} "rm -rf ${remote_path}; mkdir ${remote_path}; cd ${remote_path}; mkdir ${folder_name}"
	scp -q -r ${local_path}/${folder_name}/script ${user}@${ip}:${remote_path}/${folder_name} 
	scp -q -r ${local_path}/${folder_name}/temp ${user}@${ip}:${remote_path}/${folder_name} 
done

echo "done"


