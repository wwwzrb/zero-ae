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
    latency_list.append((str(split_stat_index(line, 2)) +' us'))
f.close()

print("----------------------")
print("Latency result:")
print(latency_list)

print("----------------------")
print("Agent CPU perf result:")
total_cpu = 0
count = 0
f = open(agent_cpu_path, 'r')
for line in f:
    if not '<not counted>' in line:
        total_cpu += (split_stat_index(line, 0))
        count += 1
    print(line, end='')
print("----------------------")
print("Control Plane: Total {0} ms CPU time in {1} ms ({2}%)".format(total_cpu, 500*count, total_cpu/5.0/count))
print("Data Plane: <not counted>")
print("----------------------")
f.close()


