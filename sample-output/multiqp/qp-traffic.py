import numpy as np
from ctypes import Structure, c_long
import matplotlib.pyplot as plt
from matplotlib.font_manager import FontProperties
import matplotlib.cm as cmx
import matplotlib.colors as colors


class TimeVal(Structure):
    _fields_ = [("tv_sec", c_long), ("tv_usec", c_long)]


def read_traffic(prefix, interval, num, size, quotas):
    global qp_num
    global host_num

    traffic = []
    time = []
    for i in range(len(qp_num)):
        traffic_repeat = []
        time_repeat = []

        file_path = prefix + '/traffic_' + '{0}' + '_' + '{1}' + '_' + '{2}' + '_' + '{3}' + '_' + '{4}' + '_' + '{5}'
        file_path = file_path.format(qp_num[i], qp_num[i], interval, num, size, quotas[i])
        # print(file_path)
        traffic_list = []
        time_list = []
        first = 1
        with open(file_path, 'r') as f:
            for line in f:
                metrics = str.split(line)

                if metrics[0] == '0':
                    traffic_repeat.append(traffic_list)
                    time_repeat.append(time_list)

                    traffic_list = []
                    time_list = []
                    first = 1
                else:
                    start_time = TimeVal(tv_sec=int(metrics[3]), tv_usec=int(metrics[4]))
                    end_time = TimeVal(tv_sec=int(metrics[5]), tv_usec=int(metrics[6]))
                    time_list.append((start_time, end_time))

                    if first:
                        first = 0
                        pre_end_time = start_time

                    total_time = (end_time.tv_sec - pre_end_time.tv_sec) * 1e6 + (end_time.tv_usec - pre_end_time.tv_usec)
                    pre_end_time = end_time
                    traffic_list.append((int(metrics[0]), int(metrics[2]), int(total_time)))

        traffic.append(traffic_repeat)
        time.append(time_repeat)

    return traffic, time


def plot_traffic(res, axis_label, name):
    fig = plt.figure(figsize=(6, 4))
    ax = fig.add_axes([0.1, 0.1, 0.8, 0.8])

    lines = []
    for i in range(len(res)):
        ph_legend, = ax.plot(np.NaN, np.NaN, color=colors[i], marker=markers[i], ms=5, mfc='w')
        lines.append(ph_legend)

        traffic = res[i]
        pre_end = 0
        x_tick = []
        for j in range(len(traffic)):
            x = [pre_end + j for j in range(0, traffic[j][2], 100)]
            # print(pre_end, traffic[j][2])
            if traffic[j][2] % 100 == 0:
                points = traffic[j][2] // 100
            else:
                points = traffic[j][2] // 100 + 1
            y = [float(traffic[j][0] * 4 * 1e6 / traffic[j][2]) / 1024] * points
            ax.plot(x, y, color=colors[i], marker=markers[i], ms=4,  mfc='w')

            pre_end = pre_end + traffic[j][2]
            x_tick.append(pre_end)

    # set x,y tick
    ax.set_xscale('log')
    ax.set_xticks([1e2, 1e3, 1e4])
    ax.set_xticklabels([0.1, 1, 10], fontproperties=font)

    ax.set_yticks([i for i in range(0, 17000, 2000)])
    ax.set_yticklabels([i for i in range(0, 17000, 2000)], fontproperties=font)

    # 设置x轴和y轴的标签
    plt.xlabel(axis_label[0], fontproperties=font)
    plt.ylabel(axis_label[1], fontproperties=font)

    # 设置图例
    ph_legend, = ax.plot(np.NaN, np.NaN, color='none')
    ax.legend([lines[0], lines[1]], [labels[0], labels[1]],
              loc='upper center',
              bbox_to_anchor=(0.18, 0.75, 0.5, 0.5), prop=font, ncol=2, labelspacing=0.2, columnspacing=0.5,
              markerfirst=False)
    ax.grid(axis='both', linestyle='--')

    # plt.show()
    for fmt in fmts:
        plt.savefig(name + '.' + fmt, format=fmt, bbox_inches='tight')


font = FontProperties()
font.set_size(20)
# font.set_name('Arial')
font.set_name('Times New Roman')
font.set_weight('bold')
fmts = ['png', 'pdf']


qp_num = [64]
quotas_wcc = [4, 2, 1, 1, 1]
# quotas_wocc = [8, 4, 4, 4, 4]
quotas_wocc = [12, 12, 12, 12, 12]
host_num = 8
interval = 1000
num = 32
size = 4

zero_prefix = './receiver'
zero_traffic_wq, zero_time_wq = read_traffic(zero_prefix, interval, num, size, quotas_wcc)

traffic_res = [zero_traffic_wq[0][0], zero_traffic_wq[0][1]]

# 绘图
tab = plt.get_cmap('tab20')
cNorm = colors.Normalize(vmin=0, vmax=tab.N)
scalarMap = cmx.ScalarMappable(norm=cNorm, cmap=tab)
colors = []
for i in [0, 6]:
    colors.append(scalarMap.to_rgba(i))
# colors = ['pink', 'lightblue', 'lightgreen']
labels = ['Zero Repeat 0', 'Zero Repeat 1', '']
markers = ['o', '^']
styles = ['-', '-.']

plot_traffic(traffic_res, ('Time (ms)', 'Throughput (MB/s)'), 'qp-traffic')