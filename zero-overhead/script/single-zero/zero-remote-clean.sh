sample_interval=$1
num=$2
size=$3 # size will be multiplied with 1K

user=root
ip="192.168.10.20"

path_prefix=~/zero-ae
folder_name=zero-overhead

local_path=${path_prefix}
remote_path=${path_prefix}

sshpass ssh ${user}@$ip "cd ${remote_path}/${folder_name}/script/single-zero; sh ./zero-clean.sh "
