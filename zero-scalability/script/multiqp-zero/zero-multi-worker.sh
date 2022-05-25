#!/bin/bash
host_num=${1}
qp_num=${2}
num=${3}   # num of registered block
size=${4}  # size of block, 1KB default MTU

user=root
ip_prefix="192.168.10."
ip_array_pm=(20 21 22 25 26 31 32 33)

path_prefix=~/zero-ae
folder_name=zero-scalability

local_path=${path_prefix}
remote_path=${path_prefix}

config_file=${local_path}/${folder_name}/config/host_list
if [ -f "${config_file}" ] ; then
	rm $config_file
fi

start_port=19875
for(( i=0;i<${qp_num};i++)) do
	for (( j=0;j<${host_num};j++)) do
		ip=${ip_prefix}${ip_array_pm[j]}
		let port=$start_port+$i
		echo "$ip,${port}" >> ${config_file}
		sshpass ssh ${user}@$ip "cd ${remote_path}/${folder_name}/script/multiqp-zero; sh ./zero-worker.sh ${port} ${num} ${size} >> temp.txt" &
		sleep 0.1
	done
done

cat ${config_file}

echo "Agent prepared..."
