#!/bin/bash
sample_interval=$1
num=$2
size=$3 # size will be multiplied with 1K
if [ ! -n $num ]; then
  echo "num is null, exit."
  exit 1
fi

path_prefix=~/zero-ae/zero-overhead
# boot zero agent
${path_prefix}/temp/agent_worker -g 3 &

sleep 1

# sample zero agent cpu
file=${path_prefix}/perf_data/single/sender/cpu_${sample_interval}_${num}_${size}
sleep_time=0.5
repeat=20
# echo "repeat: $repeat"
rm -rf $file
sh ${path_prefix}/script/zero-cpu.sh $file $repeat $sleep_time &

sleep 1

${path_prefix}/temp/client_multi $num $size &

echo "Agent Prepared..."


