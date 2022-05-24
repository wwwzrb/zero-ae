#!/bin/bash

sample_time=$1
instance_num=$2
size=$3 # size will be multiplied with 1K
ip=$4

path_prefix=~/zero-ae/zero-overhead

${path_prefix}/temp/agent_controller -g 3 -t ${sample_time} -e ${path_prefix} $ip &

# sleep 1

sleep_time=0.5
sleep_ms=500
repeat=20
# echo "repeat: $repeat"
file=${path_prefix}/perf_data/single/receiver/cpu_${sample_time}_${instance_num}_${size}
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

sh ${path_prefix}/script/visualize.sh ${sample_time} ${instance_num} ${size} single