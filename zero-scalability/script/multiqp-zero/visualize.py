import sys
import numpy as np

def split_stat_index(str, index):
    str_list = str.split(' ')
    return float(str_list[index])

def split_stat(str):
    str_list = str.split(' ')
    return str_list

# print(sys.argv)
host = int(sys.argv[1])
interval = int(sys.argv[2])
num = int(sys.argv[3])
size = int(sys.argv[4])
quota = int(sys.argv[5])
path_prefix = str(sys.argv[6])
path = path_prefix +'/perf_data/multiqp/receiver'

avg_latency = []
latency_qp = []
for i in range(host):
    latency_repeat = []
    file_path = path + '/latency_' + '{0}_{1}_{2}_{3}_{4}_{5}'
    file_path = file_path.format(host, i, interval, num, size, quota)

    f = open(file_path, 'r')
    for line in f:
        metrics = str.split(line)
        latency_repeat.append(float(metrics[2]))
    f.close()
    
    latency_qp.append(latency_repeat)

avg_latency = np.mean(np.array(latency_qp), axis=0)
print("----------------------")
print("Latency Result:")
print("----------------------")
print("Average Latency (us) across {0} hosts in {1} repeated runs:".format(host, len(avg_latency)))
print(["{0:.2f} us".format(lat) for lat in avg_latency])


print("----------------------")
print("Controller CPU:")
control_cpu = 0
control_cnt = 0
data_cpu = 0
data_cnt=0

file_path = path + '/cpu_' + '{0}_{1}_{2}_{3}_{4}'
file_path = file_path.format(host, interval, num, size, quota)
f = open(file_path, 'r')
for line in f:
    if control_cnt < 1:
        if not '<not counted>' in line:
            control_cpu += (split_stat_index(line, 0))
        control_cnt += 1
    else:
        if not '<not counted>' in line:
            data_cpu += (split_stat_index(line, 0))
        data_cnt += 1
f.close()

print("----------------------")
print("Control Plane: {0:.2f} ms CPU time in {1} ms ({2:.2f}%)".format(control_cpu/control_cnt, 500, control_cpu/5.0/control_cnt))
print("Data Plane: {0:.2f} ms CPU time in {1} ms ({2:.2f}%)".format(data_cpu/data_cnt, 500, data_cpu/5.0/data_cnt))
print("----------------------")

print("Raw CPU perf result:")
f = open(file_path, 'r')
cnt = 0
for line in f:
    if cnt < 20:
        print(line, end='')
        cnt += 1
    else:
        break
f.close()



