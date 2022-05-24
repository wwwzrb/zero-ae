# Zero
This repository holds the artifact of the paper "Zero Overhead Monitoring for Cloud-native Infrastructure using RDMA", published on ATC 2022.   

------

## System Specification
### Environment
The experiments in this paper are conducted in the following two clusters, named Cluster1 and Cluster2, respectively.   
<img src="/background/ArtifactSubmission.png" alt="Deployment">

### Hardware Dependency
Zero relies on RDMA NICs, e.g., Mellanox CX4-6.  
While both IB and RoCE are supported, we recommend the RoCEv1/2 protocol for the ease of Ethernet deployment.   
Also, we provided scripts configured as RoCE by default.  
Zero is supported by both virtualization (SR-IOV in Cluster1) and bare-metal (Cluster2) environments.  

### Software Dependency
Zero depends on Mellanox [libibverbs](https://github.com/gpudirect/libibverbs).   
If your machine can run [perftest](https://github.com/gpudirect/libibverbs), it should work well with Zero.   

## Setup

### Install Dependencies
```
sudo yum install libibverbs
```

### Prepare Zero
We recommend that you work on the root directory of the current user, i.e., `~\`. Otherwise, you will need to manually change the default **path_prefix** defined in our scripts.

```
cd ~
git clone -b zero-ae git@github.com:wwwzrb/zero-ae.git # https://github.com/wwwzrb/zero-ae.git
```

### Directory Layout
```
├── background            # ib_read_bw/lat perf result in Cluster1/2 as an reference
├── LICENSE
├── README.md             # Instructions for AE
├── sample-output         # Sample output in Cluster2 as an reference
│   ├── multiqp
│   │   └── qp-traffic.py # Script to process traffic output
│   └── redis
├── zero-overhead         # For overhead evaluation.
│   ├── perf_data
│   │   ├── redis
│   │   └── single
│   ├── script 
│   │   ├── redis-zero
│   │   └── single-zero
│   └── temp              # Excutable Zero framework and ported application.
└── zero-scalability      # For distibuted monitoring.
    ├── config
    │   ├── host_list     # Auto generated host_list by script
    │   └── host_list.bk
    ├── perf_data
    │   └── multiqp
    ├── script
    │   └── multiqp
    └── temp              # Excutable Zero framework and ported application.
```

## Evaluation
For ease of artifact evaluation (AE), we divide AE into three cases.
* **Hello World**       
Basic example to demonstrate the working flow of Zero. 
* **Zero Overhead**     
Evaluation of Zero with typical applications, e.g., Redis.
* **Zero Scalability**  
Evaluation of Zero in distributed monitoring.

### Parameters
|        |       |       | 
|  ----  | ----  | ----  |
|Agent IP:          |IP1-n              | Agent Host IP |
|Controller IP:     |IP                 | Controller Host IP|
|Total Host Num:    |host               | Total number of agents managed by controller, which equals to phyhost x virhost.|
|Physical Host Num: |phyhost            | The number of physicl hosts.|
|Virtual Host Num:  |virhost            | The number of virtual hosts (VM/container) on each physical host.|
|Sampling Interval: |interval (in us)   | Fixed period of monitoring.|
|Instance:          |instance           | The number of MRs/instances to monitor.|
|Size:              |size (in KB)       | Size of each block.|
|Quota:             |quota (n x 4KB)    | The credit n in number of pages, each page is 4KB.|


### Hello World
#### Preparation
Prepare Zero at two machines with IP1 and IP, as the monitoring agent and controller respectively.
#### Run tests
* At the agent side:
```
cd ~/zero-ae/zero-overhead/script/single-zero 
./zero-worker.sh 1000 10 4                      # Montoring 10 x 4KB data with 1s interval; 
                                                # ./zero-worker.sh interval instance size 
./zero-clean.sh                                 # Zero agent works in blocking mode and need to be released manually after each run
```

* At the controller side:
```
cd ~/zero-ae/zero-overhead/script/single-zero
./zero-controller.sh 1000 10 4 192.168.10.20    # Montoring 10 x 4KB data with 1s interval from IP 192.168.10.20
                                                # ./zero-controller.sh interval instance size IP1  
                                                # Zero controller will exit automatically.
```

Note that the controller needs to be launched after the agent is prepared, e.g., all MRs of metrics are registered via the control plane.  

Note that we only perf Zero agent CPU for a short while, as the agent is blocked after all metrics are registered.

#### Output
The agent output is written to `~/zero-ae/zero-overhead/perf_data/single/sender`, at the agent side.    
The controller output is written to `~/zero-ae/zero-overhead/perf_data/single/receiver`, at the controller side. 

### Zero Overhead
#### Preparation
Prepare Zero at two machines with IP1 and IP, as the monitoring agent and controller respectively.
#### Run tests
* At the agent side:
```
cd ~/zero-ae/zero-overhead/script/redis-zero 
./zero-worker.sh 1000 10                        # Montoring 10 x Redis instances with 1s interval
                                                # ./zero-worker.sh interval instance
./zero-clean.sh                                 # Zero agent works in blocking mode and need to be released manually after each run
```

* At the controller side:
```
cd ~/zero-ae/zero-overhead/script/redis-zero
./zero-controller.sh 1000 10 192.168.10.20      # Montoring 10 x Redis instances with 1s interval from IP 192.168.10.20
                                                # ./zero-controller.sh interval instance size IP1  
                                                # Zero controller will exit automatically.
``` 

#### Output
The agent output is written to `~/zero-ae/zero-overhead/perf_data/redis/sender`, at the agent side.    
The controller output is written to `~/zero-ae/zero-overhead/perf_data/redis/receiver`, at the controller side.   

### Zero Scalability
#### Preparation
Prepare Zero at n machines with IP1-n as the monitoring agent, where n=8 in our Cluster2.   
Prepare Zero at one machine with IP as the monitoring controller.

1. The controller can password-free login agent via ssh for ease of deployment. You can refer to `sshkey_config.sh` for ssh key configuration.
2. Distribute `~/zero-ae/zero-scalability` folder to all agents. The IP1-n need to be configured in the script according to your machine IP.
```
cd ~/zero-ae/zero-scalability/script/multiqp-zero
./zero-multi-scp.sh 8                               # copy to 8 phyhosts; 
                                                    # ./zero-multi-scp.sh phyhost
```
3. Determine parameters according to your deployment.
In our cluster2, the ECN is set with a single threshold of ~1000KB, denotes as thr.  
The number of phyhosts is 8.  
The number of virhosts is 8-128.  
The number of monitored hosts is pyhosts x virhosts = 64-1024.   
The quota is determined by thr/host.   
Note that the quota can be larger than thr/host with many non-perfect synchronized QP connections.  
In our practice, the quota is set to 1-4 x 4KB, i.e., 4/2/1/1/1 with 64/128/256/512/1024 hosts. 

#### Run tests
* Run Zero at all agents via the controller (via password-free sshpass):
```
cd ~/zero-ae/zero-scalability/script/multiqp-zero
./zero-multi-worker.sh 8 8 32 4                     # Launch Zero agent at 8 phyhosts x 8 virhosts = 64 hosts, each hosts have 32 instances x 4KB = 128 KB data 
                                                    # ./zero-multi-worker.sh phyhost virhost instance size
./zero-multi-clean.sh 8                             # Manually exit Zero agent on all phyhosts
                                                    # ./zero-multi-clean.sh phyhost
```

* Run Zero controller:
```
cd ~/zero-ae/zero-scalability/script/multiqp-zero
./zero-multi-controller.sh 64 1000 32 4 4           # Launch Zero controller to monitor 64 hosts with 1s interval, 32 instances x 4KB = 128 KB data on each host, 4 x 4KB = 16KB quota
                                                    # ./zero-multi-controller.sh host interval instance size quota
                                                    # Zero controller will exit automatically.
```   

Note that the control plane incurs high latency with many connections, we recommend no more than 512 hosts in your test. We will further optimize our control plane via parallel QP connection build-up and initialization.

#### Output
As agents are distributed across many hosts, their outputs are omitted.   
The controller output is written to `~/zero-ae/zero-scalability/perf_data/multiqp/receiver`, at the controller side.    


## License
This repository is licensed under the GNU General Public License v3.0, found in the LICENSE file. 