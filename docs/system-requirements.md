## Hardware sizing for Boundary servers

Refer to the tables below for sizing recommendations for controller nodes and worker nodes, as well as small and large use cases based on expected usage.

Controller nodes

| Size  | CPU        | Memory         | Disk capacity | Network throughput |
| ----- | ---------- | -------------- | ------------- | ------------------ |
| Small | 2 - 4 core | 8 - 16 GB RAM  | 50+ GB        | Minimum 5 Gbps     |
| Large | 4 - 8 core | 32 - 64 GB RAM | 100+ GB       | Minimum 10 Gbps    |

Worker nodes

| Size  | CPU        | Memory         | Disk capacity | Network throughput |
| ----- | ---------- | -------------- | ------------- | ------------------ |
| Small | 2 - 4 core | 8 - 16 GB RAM  | 50+ GB        | Minimum 10 Gbps    |
| Large | 4 - 8 core | 32 - 64 GB RAM | 100+ GB       | Minimum 10 Gbps    |

For each cluster size, the following table gives recommended hardware specifications for each major cloud infrastructure provider.

| Provider | Size  | Instance/VM types       |
| -------- | ----- | ----------------------- |
| AWS      | Small | m5.large , m5.xlarge    |
| AWS      | Large | m5.2xlarge , m5.4xlarge |

To help ensure predictable performance HashiCorp recommends that you avoid "burstable" CPU and storage options (such as `t2` and `t3` instance types) whose performance may degrade rapidly under continuous load.

For more information regarding system requirements, see the [Boundary system requirements](https://github.com/hashicorp/boundary/blob/main/website/content/docs/install-boundary/architecture/system-requirements.mdx) documentation.
