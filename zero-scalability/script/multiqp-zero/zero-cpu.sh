file=$1
repeat=$2
sleep_time=$3
echo "file $file"
echo "repeat $repeat"
pid=$(pidof agent_worker)
echo "pid $pid"
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

echo "perf zero-worker finished"
