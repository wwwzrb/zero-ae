#!/bin/bash
sample_interval=$1
server_num=$2

user=root
ip="192.168.10.20"

path_prefix=~/zero-ae
folder_name=zero-overhead

local_path=${path_prefix}
remote_path=${path_prefix}

sshpass ssh ${user}@$ip "cd ${remote_path}/${folder_name}/script/redis-zero; sh ./zero-worker.sh ${sample_interval} ${server_num} &" &