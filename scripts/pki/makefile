all: ca admin controller-manager kube-scheduler service-account api-server etcd kubelet kube-proxy worker
	mkdir generated
	mv *.csr generated
	mv *crt generated
	mv *.key generated
	mv *.srl generated
	mv *.cnf generated
	mkdir generated/certs-master
	mkdir generated/certs-worker
	bash copy-certs.sh
	
ca:
	sh ca.sh

admin:
	sh admin.sh

controller-manager:
	sh controller-manager.sh

kube-scheduler:
	sh kube-scheduler.sh

service-account:
	sh service-account.sh

api-server:
	sh api-server.sh

etcd:
	sh etcd.sh

kubelet:
	sh kubelet.sh

kube-proxy:
	sh kube-proxy.sh

worker:
	sh worker.sh

clean:
	rm -rf *.csr *.crt *.key *.srl *.cnf
	rm -rf generated


