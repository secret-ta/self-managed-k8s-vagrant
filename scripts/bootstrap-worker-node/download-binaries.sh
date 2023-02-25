CONTAINERD_VERSION=1.5.9
CNI_VERSION=0.8.6
RUNC_VERSION=1.1.1

wget -q --show-progress --https-only --timestamping \
    https://github.com/containerd/containerd/releases/download/v${CONTAINERD_VERSION}/containerd-${CONTAINERD_VERSION}-linux-amd64.tar.gz -P setup \
    https://github.com/containernetworking/plugins/releases/download/v${CNI_VERSION}/cni-plugins-linux-amd64-v${CNI_VERSION}.tgz -P setup \
    https://github.com/opencontainers/runc/releases/download/v${RUNC_VERSION}/runc.amd64 -P setup \
    https://storage.googleapis.com/kubernetes-release/release/v1.24.3/bin/linux/amd64/kubectl -P setup \
    https://storage.googleapis.com/kubernetes-release/release/v1.24.3/bin/linux/amd64/kube-proxy -P setup\
    https://storage.googleapis.com/kubernetes-release/release/v1.24.3/bin/linux/amd64/kubelet -P setup

mv setup/containerd-${CONTAINERD_VERSION}-linux-amd64.tar.gz setup/containerd.tar.gz
mv setup/cni-plugins-linux-amd64-v${CNI_VERSION}.tgz setup/cni-plugins.tgz
