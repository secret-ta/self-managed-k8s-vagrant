# Install binaries
{
  chmod +x kube-apiserver kube-controller-manager kube-scheduler kubectl
  sudo mv kube-apiserver kube-controller-manager kube-scheduler kubectl /usr/local/bin/
}

# Config API Server
{
  sudo mkdir -p /var/lib/kubernetes/pki

  # Only copy CA keys as we'll need them again for workers.
  sudo cp certs-master/ca.crt certs-master/ca.key certs-master/ca-proxy.crt /var/lib/kubernetes/pki
  for c in kube-apiserver service-account apiserver-kubelet-client etcd-server kube-scheduler kube-controller-manager proxy-client
  do
    sudo mv "certs-master/$c.crt" "certs-master/$c.key" /var/lib/kubernetes/pki/
  done
  sudo chown root:root /var/lib/kubernetes/pki/*
  sudo chmod 600 /var/lib/kubernetes/pki/*
}

INTERNAL_IP=$(hostname -I | awk '{print $2}' | cut -d / -f 1)
LOADBALANCER=$(dig +short loadbalancer)
MASTER_1=$(dig +short master-1)
MASTER_2=$(dig +short master-2)
POD_CIDR=10.244.0.0/16
SERVICE_CIDR=10.96.0.0/16

# Configure networking so that the master node can reach services and pods.
cat <<EOF | sudo tee /etc/netplan/route-pod-service.yaml
network:
  ethernets:
    enp0s8:
      routes:
        - to: ${POD_CIDR}
          via: 192.168.56.2${HOSTNAME: -1}
        - to: ${SERVICE_CIDR}
          via: 192.168.56.2${HOSTNAME: -1}
  version: 2
EOF
sudo netplan apply

cat <<EOF | sudo tee /etc/systemd/system/kube-apiserver.service
[Unit]
Description=Kubernetes API Server
Documentation=https://github.com/kubernetes/kubernetes

[Service]
ExecStart=/usr/local/bin/kube-apiserver \\
  --advertise-address=${INTERNAL_IP} \\
  --allow-privileged=true \\
  --apiserver-count=2 \\
  --audit-log-maxage=30 \\
  --audit-log-maxbackup=3 \\
  --audit-log-maxsize=100 \\
  --audit-log-path=/var/log/audit.log \\
  --authorization-mode=Node,RBAC \\
  --bind-address=0.0.0.0 \\
  --client-ca-file=/var/lib/kubernetes/pki/ca.crt \\
  --enable-admission-plugins=NodeRestriction,ServiceAccount \\
  --enable-bootstrap-token-auth=true \\
  --etcd-cafile=/var/lib/kubernetes/pki/ca.crt \\
  --etcd-certfile=/var/lib/kubernetes/pki/etcd-server.crt \\
  --etcd-keyfile=/var/lib/kubernetes/pki/etcd-server.key \\
  --etcd-servers=https://${MASTER_1}:2379,https://${MASTER_2}:2379 \\
  --event-ttl=1h \\
  --encryption-provider-config=/var/lib/kubernetes/encryption-config.yaml \\
  --kubelet-certificate-authority=/var/lib/kubernetes/pki/ca.crt \\
  --kubelet-client-certificate=/var/lib/kubernetes/pki/apiserver-kubelet-client.crt \\
  --kubelet-client-key=/var/lib/kubernetes/pki/apiserver-kubelet-client.key \\
  --runtime-config=api/all=true \\
  --service-account-key-file=/var/lib/kubernetes/pki/service-account.crt \\
  --service-account-signing-key-file=/var/lib/kubernetes/pki/service-account.key \\
  --service-account-issuer=https://${LOADBALANCER}:6443 \\
  --service-cluster-ip-range=${SERVICE_CIDR} \\
  --service-node-port-range=30000-32767 \\
  --tls-cert-file=/var/lib/kubernetes/pki/kube-apiserver.crt \\
  --tls-private-key-file=/var/lib/kubernetes/pki/kube-apiserver.key \\
  --requestheader-client-ca-file=/var/lib/kubernetes/pki/ca-proxy.crt \\
  --proxy-client-cert-file=/var/lib/kubernetes/pki/proxy-client.crt \\
  --proxy-client-key-file=/var/lib/kubernetes/pki/proxy-client.key \\
  --requestheader-allowed-names=aggregator,system:serviceaccount:kube-system:metrics-server \\
  --requestheader-extra-headers-prefix=X-Remote-Extra- \\
  --requestheader-group-headers=X-Remote-Group \\
  --requestheader-username-headers=X-Remote-User \\
  --enable-aggregator-routing=true \\
  --v=2
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

#Config Controller Manager
sudo mv kubeconfig-master/kube-controller-manager.kubeconfig /var/lib/kubernetes/
cat <<EOF | sudo tee /etc/systemd/system/kube-controller-manager.service
[Unit]
Description=Kubernetes Controller Manager
Documentation=https://github.com/kubernetes/kubernetes

[Service]
ExecStart=/usr/local/bin/kube-controller-manager \\
  --allocate-node-cidrs=true \\
  --authentication-kubeconfig=/var/lib/kubernetes/kube-controller-manager.kubeconfig \\
  --authorization-kubeconfig=/var/lib/kubernetes/kube-controller-manager.kubeconfig \\
  --bind-address=127.0.0.1 \\
  --client-ca-file=/var/lib/kubernetes/pki/ca.crt \\
  --cluster-cidr=${POD_CIDR} \\
  --cluster-name=kubernetes \\
  --cluster-signing-cert-file=/var/lib/kubernetes/pki/ca.crt \\
  --cluster-signing-key-file=/var/lib/kubernetes/pki/ca.key \\
  --controllers=*,bootstrapsigner,tokencleaner \\
  --kubeconfig=/var/lib/kubernetes/kube-controller-manager.kubeconfig \\
  --leader-elect=true \\
  --node-cidr-mask-size=24 \\
  --requestheader-client-ca-file=/var/lib/kubernetes/pki/ca.crt \\
  --root-ca-file=/var/lib/kubernetes/pki/ca.crt \\
  --service-account-private-key-file=/var/lib/kubernetes/pki/service-account.key \\
  --service-cluster-ip-range=${SERVICE_CIDR} \\
  --use-service-account-credentials=true \\
  --v=2
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

#Config Kube Scheduler
sudo mv kubeconfig-master/kube-scheduler.kubeconfig /var/lib/kubernetes/
cat <<EOF | sudo tee /etc/systemd/system/kube-scheduler.service
[Unit]
Description=Kubernetes Scheduler
Documentation=https://github.com/kubernetes/kubernetes

[Service]
ExecStart=/usr/local/bin/kube-scheduler \\
  --kubeconfig=/var/lib/kubernetes/kube-scheduler.kubeconfig \\
  --leader-elect=true \\
  --v=2
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

sudo chmod 600 /var/lib/kubernetes/*.kubeconfig

{
  sudo systemctl daemon-reload
  sudo systemctl enable kube-apiserver kube-controller-manager kube-scheduler
  sudo systemctl start kube-apiserver kube-controller-manager kube-scheduler
}

