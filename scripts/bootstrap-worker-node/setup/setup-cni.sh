# Install CRI
{
  sudo mkdir -p /opt/cni/bin

  sudo chmod +x runc.amd64
  sudo mv runc.amd64 /usr/local/bin/runc

  sudo tar -xzvf containerd.tar.gz -C /usr/local
  sudo tar -xzvf cni-plugins.tgz -C /opt/cni/bin
}

cat <<EOF | sudo tee /etc/systemd/system/containerd.service
[Unit]
Description=containerd container runtime
Documentation=https://containerd.io
After=network.target local-fs.target

[Service]
ExecStartPre=-/sbin/modprobe overlay
ExecStart=/usr/local/bin/containerd

Type=notify
Delegate=yes
KillMode=process
Restart=always
RestartSec=5
# Having non-zero Limit*s causes performance problems due to accounting overhead
# in the kernel. We recommend using cgroups to do container-local accounting.
LimitNPROC=infinity
LimitCORE=infinity
LimitNOFILE=infinity
# Comment TasksMax if your systemd version does not supports it.
# Only systemd 226 and above support this version.
TasksMax=infinity
OOMScoreAdjust=-999

[Install]
WantedBy=multi-user.target
EOF

{
  sudo systemctl enable containerd
  sudo systemctl start containerd
}
