#!/bin/bash
port=$1
num=$2   # num of registered block
size=$3  # size of block, 1KB default MTU
if [ ! -n $num ]; then
  echo "num is null, exit."
  exit 1
fi

# systemctl stop netdata
# boot zero agent
../../temp/agent_worker -g 3 -p ${port} -n ${num} -s ${size} &

# sleep 1

# # sample zero agent cpu
# file=../../perf_data/multi/sender/cpu_${num}_${size}
# sleep_time=0.5
# repeat=20
# # echo "repeat: $repeat"
# rm -rf $file
# sh ../zero-cpu.sh $file $repeat $sleep_time &

# sleep 1

# ../../temp/client_multi $num $size &



