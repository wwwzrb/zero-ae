sample_interval=$1
num=$2
case=$3

user=root
ip="192.168.10.33"

path_prefix=~/zero-ae
folder_name=zero-overhead

local_path=${path_prefix}
remote_path=${path_prefix}

# Copy agent CPU perf from sender
rsync -r ${user}@${ip}:${remote_path}/${folder_name}/perf_data/${case}/sender ${local_path}/${folder_name}/perf_data/${case}

latency=${local_path}/${folder_name}/perf_data/${case}/receiver/latency_${sample_interval}_${num}
controller_cpu=${local_path}/${folder_name}/perf_data/${case}/receiver/cpu_${sample_interval}_${num}
agent_cpu=${local_path}/${folder_name}/perf_data/${case}/sender/cpu_${sample_interval}_${num}

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