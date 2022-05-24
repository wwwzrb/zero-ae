host_num=$1
sample_interval=$2
num=$3
size=$4
quota=$5
path_prefix=${6}

python3 ${path_prefix}/script/multiqp-zero/visualize.py ${host_num} ${sample_interval} ${num} ${size} ${quota} ${path_prefix}
