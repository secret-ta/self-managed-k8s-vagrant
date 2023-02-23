CONTAINERD_VERSION=1.5.9
CNI_VERSION=0.8.6
RUNC_VERSION=1.1.1

wget -q --show-progress --https-only --timestamping \
    https://github.com/containerd/containerd/releases/download/v${CONTAINERD_VERSION}/containerd-${CONTAINERD_VERSION}-linux-amd64.tar.gz -O setup/containerd.tar.gz \
    https://github.com/containernetworking/plugins/releases/download/v${CNI_VERSION}/cni-plugins-linux-amd64-v${CNI_VERSION}.tgz -O setup/cni.tgz \
    https://github.com/opencontainers/runc/releases/download/v${RUNC_VERSION}/runc.amd64 -P setup \
    https://storage.googleapis.com/kubernetes-release/release/v1.24.3/bin/linux/amd64/kubectl -P setup \
    https://storage.googleapis.com/kubernetes-release/release/v1.24.3/bin/linux/amd64/kube-proxy -P setup\
    https://storage.googleapis.com/kubernetes-release/release/v1.24.3/bin/linux/amd64/kubelet -P setup

vagrant scp setup-tls-bootstrap.sh master-1:~/
vagrant ssh master-1 -- -t 'bash setup-tls-bootstrap.sh'

{
for instance in worker-1 worker-2; do
    vagrant scp setup ${instance}:~/
done

for instance in worker-1 worker-2; do
    vagrant ssh ${instance} -- -t 'mv setup/* .; rm -rf setup;'
    vagrant ssh ${instance} -- -t 'bash setup-cni.sh; bash setup-node.sh;'
done
}

vagrant scp approve-csr.sh master-1:~/
vagrant ssh master-1 -- -t 'bash approve-csr.sh'

