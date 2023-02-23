sudo apt-get update && sudo apt-get install -y haproxy

MASTER_1=$(dig +short master-1)
MASTER_2=$(dig +short master-2)
LOADBALANCER=$(dig +short loadbalancer)

cat <<EOF | sudo tee /etc/haproxy/haproxy.cfg
frontend kubernetes
    bind ${LOADBALANCER}:6443
    option tcplog
    mode tcp
    default_backend kubernetes-master-nodes

backend kubernetes-master-nodes
    mode tcp
    balance roundrobin
    option tcp-check
    server master-1 ${MASTER_1}:6443 check fall 3 rise 2
    server master-2 ${MASTER_2}:6443 check fall 3 rise 2
EOF
sudo systemctl restart haproxy