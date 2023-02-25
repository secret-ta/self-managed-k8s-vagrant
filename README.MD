## Prerequisites
- Vagrant
- Virtualbox

## How to build the cluster
1. Download required binaries
```
make download-binaries
```
2. Provision all (Infra + Bootstrap K8s Components)
```
make all
```
3. Approve all pending certificates
```
for csr in $(kubectl get csr | grep -i pending | awk '{ print $1 }'); do
    kubectl certificate approve $csr
done
```
