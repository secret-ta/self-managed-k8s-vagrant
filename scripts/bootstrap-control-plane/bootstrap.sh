# wget -q --show-progress --https-only --timestamping \
#   "https://storage.googleapis.com/kubernetes-release/release/v1.24.3/bin/linux/amd64/kube-apiserver" -P setup \
#   "https://storage.googleapis.com/kubernetes-release/release/v1.24.3/bin/linux/amd64/kube-controller-manager" -P setup \
#   "https://storage.googleapis.com/kubernetes-release/release/v1.24.3/bin/linux/amd64/kube-scheduler" -P setup \
#   "https://storage.googleapis.com/kubernetes-release/release/v1.24.3/bin/linux/amd64/kubectl" -P setup
  
{
for instance in master-1 master-2; do
    vagrant scp setup ${instance}:~/
done

for instance in master-1 master-2; do
    vagrant ssh ${instance} -- -t 'mv setup/* .; rm -rf setup;'
    vagrant ssh ${instance} -- -t 'bash setup-control-plane.sh'
done
}