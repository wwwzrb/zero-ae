#!/bin/bash

host_num=$1
sample_interval=$2
num=$3
size=$4
quota=$5

path_prefix=~/zero-ae/zero-scalability

${path_prefix}/temp/agent_controller -g 3 -n ${host_num} -t ${sample_interval} -q ${quota} -e ${path_prefix} &

sleep_time=0.5
sleep_ms=500
repeat=40
# echo "repeat: $repeat"
file=${path_prefix}/perf_data/multiqp/receiver/cpu_${host_num}_${sample_interval}_${num}_${size}_${quota}
rm -rf $file

pid=$(ps -ef | grep "agent_controller" | awk '{print $2}'| head -n 1)
for ((i=1;i<=$repeat;i++));
do
	perf stat -e cpu-clock -x , -p $pid -o $file --append -- sleep $sleep_time
done

tmp_file=${file}_tmp  
sed -r -i '/^\#/d' $file
sed -r -i '/^[  ]*$/d' $file
awk -F ',' '{print $1,$6}' $file > $tmp_file
rm -rf $file
mv $tmp_file $file

kill -9 $(pidof agent_controller)
echo "agent_controller killed"

kill -9 $(pidof rdma_monitor)
echo "rdma_monitor killed"
