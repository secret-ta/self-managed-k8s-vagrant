sudo swapoff -a

sudo mkdir -p \
  /var/lib/kubelet/pki \
  /var/lib/kube-proxy \
  /var/lib/kubernetes/pki \
  /var/run/kubernetes

{
  chmod +x kubectl kube-proxy kubelet
  sudo mv kubectl kube-proxy kubelet /usr/local/bin/
}

{
  sudo mv certs-worker/ca.crt certs-worker/kube-proxy.crt certs-worker/kube-proxy.key /var/lib/kubernetes/pki
  sudo chown root:root /var/lib/kubernetes/pki/*
  sudo chmod 600 /var/lib/kubernetes/pki/*
}

LOADBALANCER=$(dig +short loadbalancer)
POD_CIDR=10.244.0.0/16
SERVICE_CIDR=10.96.0.0/16
CLUSTER_DNS=$(echo $SERVICE_CIDR | awk 'BEGIN {FS="."} ; { printf("%s.%s.%s.10", $1, $2, $3) }')

{
  sudo kubectl config --kubeconfig=/var/lib/kubelet/bootstrap-kubeconfig \
    set-cluster bootstrap --server="https://${LOADBALANCER}:6443" --certificate-authority=/var/lib/kubernetes/pki/ca.crt

  sudo kubectl config --kubeconfig=/var/lib/kubelet/bootstrap-kubeconfig \
    set-credentials kubelet-bootstrap --token=07401b.f395accd246ae52d

  sudo kubectl config --kubeconfig=/var/lib/kubelet/bootstrap-kubeconfig \
    set-context bootstrap --user=kubelet-bootstrap --cluster=bootstrap

  sudo kubectl config --kubeconfig=/var/lib/kubelet/bootstrap-kubeconfig \
    use-context bootstrap
}

cat <<EOF | sudo tee /var/lib/kubelet/kubelet-config.yaml
kind: KubeletConfiguration
apiVersion: kubelet.config.k8s.io/v1beta1
authentication:
  anonymous:
    enabled: false
  webhook:
    enabled: true
  x509:
    clientCAFile: /var/lib/kubernetes/pki/ca.crt
authorization:
  mode: Webhook
clusterDomain: "cluster.local"
clusterDNS:
  - ${CLUSTER_DNS}
registerNode: true
resolvConf: /run/systemd/resolve/resolv.conf
rotateCertificates: true
runtimeRequestTimeout: "15m"
serverTLSBootstrap: true
EOF

cat <<EOF | sudo tee /etc/systemd/system/kubelet.service
[Unit]
Description=Kubernetes Kubelet
Documentation=https://github.com/kubernetes/kubernetes
After=containerd.service
Requires=containerd.service

[Service]
ExecStart=/usr/local/bin/kubelet \\
  --bootstrap-kubeconfig="/var/lib/kubelet/bootstrap-kubeconfig" \\
  --config=/var/lib/kubelet/kubelet-config.yaml \\
  --kubeconfig=/var/lib/kubelet/kubeconfig \\
  --cert-dir=/var/lib/kubelet/pki/ \\
  --container-runtime-endpoint=unix:///var/run/containerd/containerd.sock \\
  --v=2
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

{
  sudo mv kubeconfig-worker/kube-proxy.kubeconfig /var/lib/kube-proxy/
  sudo chown root:root /var/lib/kube-proxy/kube-proxy.kubeconfig
  sudo chmod 600 /var/lib/kube-proxy/kube-proxy.kubeconfig
}

cat <<EOF | sudo tee /var/lib/kube-proxy/kube-proxy-config.yaml
kind: KubeProxyConfiguration
apiVersion: kubeproxy.config.k8s.io/v1alpha1
clientConnection:
  kubeconfig: "/var/lib/kube-proxy/kube-proxy.kubeconfig"
mode: "iptables"
clusterCIDR: ${POD_CIDR}
EOF

cat <<EOF | sudo tee /etc/systemd/system/kube-proxy.service
[Unit]
Description=Kubernetes Kube Proxy
Documentation=https://github.com/kubernetes/kubernetes

[Service]
ExecStart=/usr/local/bin/kube-proxy \\
  --config=/var/lib/kube-proxy/kube-proxy-config.yaml
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

{
  sudo systemctl daemon-reload
  sudo systemctl enable kubelet kube-proxy
  sudo systemctl start kubelet kube-proxy
}

while ! (sudo systemctl -q is-active kubelet.service);
do
echo waiting kubelet;
done
