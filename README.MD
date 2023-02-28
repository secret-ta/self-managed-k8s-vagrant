## Prerequisites
- Vagrant
- Virtualbox

## How to build the cluster
1. Install vagrant-scp plugin
```
vagrant plugin install vagrant-scp
```
2. Download required binaries
```
make download-binaries
```
3. Provision all (Infra + Bootstrap K8s Components)
```
make all
```
4. Approve all pending certificates
```
for csr in $(kubectl get csr | grep -i pending | awk '{ print $1 }'); do
    kubectl certificate approve $csr
done
```

## How to login to Kubernetes Dashboard
1. Create a secure channel to your Kubernetes cluster
```
kubectl proxy
```
2. Access K8s Dashboard At:
```
http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/
```
3. Create Bearer Token
```
kubectl -n kubernetes-dashboard create token admin-user
```
4. Copy & Paste it into the `Enter token` field on the login screen
![alt text](doc/signin.png?raw=true)

5. Click the Sign in button and that's it. You are now logged in as an admin.

