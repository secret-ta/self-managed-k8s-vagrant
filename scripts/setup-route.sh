set -ex
POD_CIDR=10.244.0.0/16
SERVICE_CIDR=10.96.0.0/16

# Configure networking so that the master node can reach services and pods.
sudo ip route add ${POD_CIDR} via 192.168.56.2${HOSTNAME: -1}
sudo ip route add ${SERVICE_CIDR}  via 192.168.56.2${HOSTNAME: -1}
