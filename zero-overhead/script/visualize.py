import sys

def split_stat_index(str, index):
    str_list = str.split(' ')
    return float(str_list[index])

def split_stat(str):
    str_list = str.split(' ')
    return str_list

path_list = sys.argv
# print(path_list)
latency_path = path_list[1]
agent_cpu_path = path_list[2]

latency_list = []
f = open(latency_path, 'r')
for line in f:
    latency_list.append(split_stat_index(line, 2))
f.close()

print("----------------------")
print("Latency result:")
print("----------------------")
print("Latency in {0} repeated runs:".format(len(latency_list)))
print(["{0:.1f} us".format(lat) for lat in latency_list])

print("----------------------")
print("Agent CPU:")
total_cpu = 0
count = 0
f = open(agent_cpu_path, 'r')
for line in f:
    if not '<not counted>' in line:
        total_cpu += (split_stat_index(line, 0))
        count += 1
f.close()

print("----------------------")
print("Control Plane: Total {0:.2f} ms CPU time in {1} ms ({2:.2f}%)".format(total_cpu, 500*count, total_cpu/5.0/count))
print("Data Plane: <not counted>")
print("----------------------")

print("Raw CPU perf result:")
f = open(agent_cpu_path, 'r')
cnt = 0
for line in f:
    if cnt < 20:
        print(line, end='')
        cnt += 1
    else:
        break
f.close()


