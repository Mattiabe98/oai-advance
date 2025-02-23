# Helm Chart for OAI Distributed Unit (OAI-DU)

This helm-chart is only tested for [RF Simulated oai-du](https://gitlab.eurecom.fr/oai/openairinterface5g/-/blob/develop/radio/rfsimulator/README.md). 

Though it is designed to work with split 8 radio units or USRPs. In `template/deployment.yaml` there is a section to use it with USB based USRPs. The option to use RFSIM, USRPs or Radio Units is decided via configuration file. The container image always remains the same. 

Before using this helm-chart we recommend you read about OAI codebase and its working from the documents listed on [OAI gitlab](https://gitlab.eurecom.fr/oai/openairinterface5g/-/tree/develop/doc)

**Note**: This chart is tested on [Minikube](https://minikube.sigs.k8s.io/docs/) and [Red Hat Openshift](https://www.redhat.com/fr/technologies/cloud-computing/openshift) 4.10-4.16. RFSIM requires minimum 2CPU and 2Gi RAM. 

## Introduction

To know more about the feature set of OpenAirInterface you can check it [here](https://gitlab.eurecom.fr/oai/openairinterface5g/-/blob/develop/doc/FEATURE_SET.md#openairinterface-5g-nr-feature-set). 

The [codebase](https://gitlab.eurecom.fr/oai/openairinterface5g/-/tree/develop) for gNB, CU, DU, CU-CP/CU-UP, NR-UE is the same. Everyweek on [docker-hub](https://hub.docker.com/r/oaisoftwarealliance/oai-gnb) our [Jenkins Platform](https://jenkins-oai.eurecom.fr/view/RAN/) publishes two docker-images 

1. `oaisoftwarealliance/oai-gnb` for monolithic gNB, DU, CU, CU-CP 
2. `oaisoftwarealliance/oai-nr-cuup` for CU-UP. 

Each image has develop tag and a dedicated week tag for example `2024.w32`. We only publish Ubuntu 22.04 images. We do not publish RedHat/UBI images. These images you have to build from the source code on your RedHat systems or Openshift Platform. You can follow this [tutorial](../../../openshift/README.md) for that.

The helm chart of OAI-DU creates multiples Kubernetes resources,

1. Service
2. Role Base Access Control (RBAC) (role and role bindings)
3. Deployment
4. Configmap
5. Service account
6. Network-attachment-definition (Optional only when multus is used)

The directory structure

```
.
├── Chart.yaml
├── templates
│   ├── configmap.yaml
│   ├── deployment.yaml
│   ├── _helpers.tpl
│   ├── multus.yaml
│   ├── NOTES.txt
│   ├── rbac.yaml
│   ├── serviceaccount.yaml
│   └── service.yaml
└── values.yaml
```

## Parameters

[Values.yaml](./values.yaml) contains all the configurable parameters. Below table defines the configurable parameters. You need a dedicated interface for Fronthaul.

|Parameter                       |Allowed Values                 |Remark                           |
|--------------------------------|-------------------------------|---------------------------------|
|kubernetesDistribution                  |Vanilla/Openshift              |Vanilla Kubernetes or Openshift  |
|nfimage.repository              |Image Name                     |                                 |
|nfimage.version                 |Image tag                      |                                 |
|nfimage.pullPolicy              |IfNotPresent or Never or Always|                                 |
|imagePullSecrets.name           |String                         |Good to use for docker hub       |
|serviceAccount.create           |true/false                     |                                 |
|serviceAccount.annotations      |String                         |                                 |
|serviceAccount.name             |String                         |                                 |
|podSecurityContext.runAsUser    |Integer (0,65534)              |                                 |
|podSecurityContext.runAsGroup   |Integer (0,65534)              |                                 |
|multus.defaultGateway           |Ip-Address                     |default route in the pod         |
|multus.f1Interface.create       |true/false                     |                                 |
|multus.f1Interface.ipAdd        |Ip-Address                     |                                 |
|multus.f1Interface.netmask      |netmask                        |                                 |
|multus.f1Interface.gateway      |Ip-Address                     |                                 |
|multus.f1Interface.routes       |Json                           |Routes you want to add in the pod|
|multus.f1Interface.hostInterface|host interface                 |Host machine interface name      |
|multus.ruInterface.create       |true/false                     |                                 |
|multus.ruInterface.ipAdd        |Ip-Address                     |                                 |
|multus.ruInterface.netmask      |netmask                        |                                 |
|multus.ruInterface.gateway      |Ip-Address                     |                                 |
|multus.ruInterface.hostInterface|host interface                 |Host machine interface name      |
|multus.ruInterface.mtu          |Integer                        ||Range [0, Parent interface MTU] |


The config parameters mentioned in `config` block of `values.yaml` are limited on purpose to maintain simplicity. They do not allow changing a lot of parameters for oai-du. If you want to use your own configuration file for oai-du. It is recommended to copy it in `templates/configmap.yaml`. The command line for gnb is provided in `config.useAdditionalOptions`.

**NOTE**: The charts are configured to be used with primary CNI of Kubernetes. When you will mount the configuration file you have to define static ip-addresses for F1 and RU. Most of the primary CNIs do not allow static ip-address allocation. To overcome this we are using multus-cni with static ip-address allocation. If you are using DU in RF simulated mode then you need minimum one multus interface which you can use for F1 and RU. If you want to use DU with hardware RU then you need a dedicated interface for Fronthaul.

You can find [here](https://gitlab.eurecom.fr/oai/openairinterface5g/-/tree/develop/targets/PROJECTS/GENERIC-NR-5GC/CONF) different sample configuration files for different bandwidths and frequencies. The binary of oai-gnb is called as `nr-softmodem`. To know more about its functioning and command line parameters you can visit this [page](https://gitlab.eurecom.fr/oai/openairinterface5g/-/blob/develop/doc/RUNMODEM.md)

## Advanced Debugging Parameters

Only needed if you are doing advanced debugging

|Parameter                        |Allowed Values                 |Remark                                        |
|---------------------------------|-------------------------------|----------------------------------------------|
|start.gnbdu                      |true/false                     |If true gnbdu container will go in sleep mode   |
|start.tcpdump                    |true/false                     |If true tcpdump container will go in sleepmode|
|includeTcpDumpContainer          |true/false                     |If false no tcpdump container will be there   |
|tcpdumpimage.repository          |Image Name                     |                                              |
|tcpdumpimage.version             |Image tag                      |                                              |
|tcpdumpimage.pullPolicy          |IfNotPresent or Never or Always|                                              |
|persistent.sharedvolume          |true/false                     |Save the pcaps in a shared volume with NRF    |
|resources.define                 |true/false                     |                                              |
|resources.limits.tcpdump.cpu     |string                         |Unit m for milicpu or cpu                     |
|resources.limits.tcpdump.memory  |string                         |Unit Mi/Gi/MB/GB                              |
|resources.limits.nf.cpu          |string                         |Unit m for milicpu or cpu                     |
|resources.limits.nf.memory       |string                         |Unit Mi/Gi/MB/GB                              |
|resources.requests.tcpdump.cpu   |string                         |Unit m for milicpu or cpu                     |
|resources.requests.tcpdump.memory|string                         |Unit Mi/Gi/MB/GB                              |
|resources.requests.nf.cpu        |string                         |Unit m for milicpu or cpu                     |
|resources.requests.nf.memory     |string                         |Unit Mi/Gi/MB/GB                              |
|readinessProbe                   |true/false                     |default true                                  |
|livenessProbe                    |true/false                     |default false                                 |
|terminationGracePeriodSeconds    |5                              |In seconds (default 5)                        |
|nodeSelector                     |Node label                     |                                              |
|nodeName                         |Node Name                      |                                              |

## How to use

0. Make sure the core network is running else you need to first start the core network. You can follow any of the below links
  - [OAI 5G Core Basic](../../oai-5g-basic/README.md)
  - [OAI 5G Core Mini](../../oai-5g-mini/README.md)
1. Configure the `parent` interface for `f1` based on your Kubernetes cluster worker nodes. 

### F1 split only

Make sure core network and `cu` is running before starting the `du`

```bash
helm install oai-cu ../oai-cu
#wait for cu to start
helm install oai-du .
```
### F1 and E1 split

```bash
helm install oai-cu-cp ../oai-cu-cp 
#wait for cu-cp to start
helm install oai-cu-up ../oai-cu-up 
helm install oai-du .
```

### Connect the UE

1. Deploy NR-UE

```bash
helm install oai-nr-ue ../oai-nr-ue
```

2. Once NR-UE is connected you can go inside the pod and ping via `oai` interface. If you do not see this interface then the UE is not connected to gNB or have some issues at core network.

```bash
kubectl exec -it <oai-nr-ue-pod-name> -- bash
#ping towards spgwu/upf
ping -I oaitun_ue1 12.1.1.1
#ping towards google dns
ping -I oaitun_ue1 8.8.8.8
```

## Note

1. If you are using multus then make sure it is properly configured and if you don't have a gateway for your multus interface then avoid using gateway and defaultGateway parameter. Either comment them or leave them empty. Wrong gateway configuration can create issues with pod networking and pod will not be able to resolve service names.
