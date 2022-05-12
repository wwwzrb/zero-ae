# What is Zero?
------
Zero is a novel general monitoring framework for application, system(kernel) and eBpf metrics. Zero adopts a novel design paradigm different from the traditional monitor design, which is designed to be decoupled from the monitored infrastructure:
* Zero needs no active collectors. Metrics to be monitored only need to register at the shared memory. 
*  Zero performs no operations on the raw metrics. All calculations are offloaded to the remote side. 
*  Zero uses *one-sided* remote direct memory access (RDMA) operations, i.e., RDMA read, to obtain raw metrics, which bypasses the host CPU/kernel.

------
Zero thus achieves three properties:
* Zero overhead: zero CPU and zero COPY at the monitored side.
* Low latency: microsecond-level (us) latency.
* High throughput: support massive metrics.

# Zero design
------

<img src="/background/monitor-zero.png" alt="Zero system architecture">

------
Zero framework consist of local agent and remote controller:

* **Zero Agent.**  Zero agent keeps in blocking mode for most of time with no CPU occupation. While traditional monitor actively collect, process and upload monitoring metrics, Zero agent offloads all these workloads to remote controller. Zero agent's control plane has two main functionalities: i) it manages QP connections with the Zero controller, ii) it provides universal interface for users to register their application/system metric into the shared memory.  Zero agent's data plane is based on shared memory to achieve zero copy and avoid any extra memory footprint.

* **Zero Controller.** Zero controller initiates RDMA read on the shared memory to get the raw metrics, which bypasses the host CPU/kernel. The raw metrics are then processed by reproducing the same procedure at the monitored side. Zero assigns one QP connection for each host in general case, as the number of QP connections are limited by the RNIC hardware resource. Zero may extend QP connections for application/system monitoring with high priority. In distributed monitoring, Zero controller schedules on QP connections of multiple hosts globally to avoid incast and ensure the desired latency.

# Building Zero
------
Zero can be compiled and used on Linux-based operating system. It depends on Mellanox [libibverbs](https://github.com/gpudirect/libibverbs).
It is as simple as:
```
% make
```

In the test environment, new version of GCC/G++ is required:
```
% scl --list
% scl enable devtoolset-8 bash
```

The executable files will be generated at the `./temp` directory:
* **Zero Local Agent:** `agent_worker`
*  **Zero Remote Controller:** `agent_controller`
*  **Toy Example for Test:** `client_test`
Clean generated files and directories:
```
% make clean
```

# Running Zero

------
Run **Zero Agent** at local host:
```
% ./temp/agent_worker
```
Run **Zero Controller** at local host:
```
% ./temp/agent_controller 127.0.0.1
```
Run **Zero Controller** at remote host to monitor local host:
```
% ./temp/agent_controller local_host_ip
```

## Toy examples

------
Taking four parameters as input:
* opcode
  * 0: deregister
  * 1: register NULL addr and alloc at shared memory
  * else: register existing addr at shared memory
* length of metric
* key of metric
* content of metric
```
% ./temp/client_test1 opcode length metric_key str
```

## Redis
------
We have open sourced [Redis](http://gitlab.alibaba-inc.com/wz249428/zero/tree/redis-6.0.8) with Zero support. Please refer to [Redis](http://gitlab.alibaba-inc.com/wz249428/zero/tree/redis-6.0.8) for more details. 

The following modifications are made:

* All metrics are managed by the Zero interface.
	* Defined as pointer.
	* Allocated by Zero interface with continuous memory.
	* Updated by Redis.	 
* All metrics are (de)registered at the Zero agent when Redis server starts/stops.
	* Metric address, type and size are recorded at local agent.
	* Metric memory is interpreted as struct at remote controller.
	* Metric process is offloaded to remote controller.

------
Zero vs. Traditional([netdata](https://github.com/netdata/netdata), [promethus](https://github.com/prometheus/prometheus)):

<img src="/background/monitor-design.png" alt="Zero vs. Traditional">

* **Traditional Monitor:** Redis provides INFO command to export monitoring metrics. Traditional monitor needs to frequently send INFO request to Redis server, which has large CPU overhead and may disturb Redis service with high workload.
* **Zero Monitor:** Redis only need to register at Zero agent then do nothing.

## Kernel
------
Coming soon!
## eBpf
------
Coming soon!

# Zero internals

------

## Source code layout
```
.
├── example
│   └── client_test1.c
├── include
│   ├── agent.h
│   ├── common.h
│   ├── pri_queue.c
│   ├── pri_queue.h
│   ├── redis.c
│   └── redis.h
├── interface
│   ├── common.h
│   ├── Rtrace_verbs.c
│   └── Rtrace_verbs.h
├── Makefile
└── src
    ├── agent_controller.c
    └── agent_worker.c
```

------

## include
------
Define common headers and tools.
* **Redis:** redis.h/redis.c are used to interpret and process Redis metrics.

## src
------
Implement Zero framework.
* **Zero Local Agent:** `agent_worker.c`
*  **Zero Remote Controller:** `agent_controller.c`

## interface
------
Define common interface for application, kernel and eBpf metrics.
* **Register metrics:**
```
void* rtrace_reg_mr(void *start, size_t length, int metric_key);
```
* **Deregister metrics:**
```
int rtrace_dereg_mr(int metric_key);
```
* **Mange metrics:**
We further add functionalities to manage application metrics. Please refer to [Redis](http://gitlab.alibaba-inc.com/wz249428/zero/tree/redis-6.0.8) for more details. 
