nic=$1
flag=$2

prefix=/sys/class/net/${nic}/ecn/roce_np/enable/

for(( i=0;i<8;i++)) do
        path=${prefix}${i}
	echo ${path}
        echo ${flag} > ${path}
done
