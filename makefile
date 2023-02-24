shutdown:
	vagrant halt

power-on:
	vagrant up

all: vm pki kubeconfig encryption-config bootstrap-etcd bootstrap-control-plane bootstrap-nlb bootstrap-worker-node misc

vm:
	vagrant destroy -f
	vagrant up

pki:
	make -C scripts/pki clean
	make -C scripts/pki all

kubeconfig:
	make -C scripts/kubeconfig clean
	make -C scripts/kubeconfig all

encryption-config:
	make -C scripts/encryption-config clean
	make -C scripts/encryption-config all

bootstrap-etcd:
	make -C scripts/bootstrap-etcd all

bootstrap-control-plane:
	make -C scripts/bootstrap-control-plane all

bootstrap-nlb:
	make -C scripts/bootstrap-nlb all

bootstrap-worker-node:
	make -C scripts/bootstrap-worker-node all

misc:
	make -C scripts/configure-kubectl all
	make -C scripts/provision-pod-network all
	make -C scripts/rbac-apiserver-to-kubelet all
	make -C scripts/deploy-dns-addon all


