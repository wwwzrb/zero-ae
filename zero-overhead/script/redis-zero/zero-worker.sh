#!/bin/bash
sample_interval=$1
server_num=$2
start_port=8080
if [ ! $1 ]; then
  echo "sample interval is null, exit."
  exit 1
fi
if [ ! $2 ]; then
  echo "server num is null, exit."
  exit 1
fi
echo "sample_interval = ${sample_interval}" # for file identity with remote
echo "server_num = ${server_num}"

path_prefix=~/zero-ae/zero-overhead
# boot zero agent
${path_prefix}/temp/agent_worker -g 3 &

sleep 1

for ((i=0; i<server_num; i++))
do
	let "port=$start_port+$i"
	${path_prefix}/temp/redis-server --port $port &
	sleep 0.2
done

# sample zero agent cpu
file=${path_prefix}/perf_data/redis/sender/cpu_${sample_interval}_${server_num}
sleep_time=0.5
sleep_ms=500
repeat=20
# echo "repeat: $repeat"
rm -rf $file
sh ${path_prefix}/script/zero-cpu.sh $file $repeat $sleep_time &

sleep 10

echo "CPU perf result:"
cat ${file}
