sample_interval=$1
num=$2
size=$3 # size will be multiplied with 1K
case=$4

user=root
ip="192.168.10.20"

path_prefix=~/zero-ae
folder_name=zero-overhead

local_path=${path_prefix}
remote_path=${path_prefix}

# Copy agent CPU perf from sender
rsync -r ${user}@${ip}:${remote_path}/${folder_name}/perf_data/${case}/sender ${local_path}/${folder_name}/perf_data/${case}

latency=${local_path}/${folder_name}/perf_data/${case}/receiver/latency_${sample_interval}_${num}_${size}
controller_cpu=${local_path}/${folder_name}/perf_data/${case}/receiver/cpu_${sample_interval}_${num}_${size}
agent_cpu=${local_path}/${folder_name}/perf_data/${case}/sender/cpu_${sample_interval}_${num}_${size}

python3 ${local_path}/${folder_name}/script/visualize.py ${latency} ${agent_cpu} 

# # TODO! replace with python script
# echo "-----------------------------"
# echo "Latency result:"
# cat ${latency}

# # echo "-----------------------------"
# # echo "Controller CPU perf result:"
# # cat ${controller_cpu}

# echo "-----------------------------"
# echo "Agent CPU perf result:"
# cat ${agent_cpu}