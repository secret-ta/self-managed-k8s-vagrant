all:
	bash generate.sh
	mkdir generated
	mv *.kubeconfig generated
	mkdir generated/kubeconfig-master
	mkdir generated/kubeconfig-worker
	bash distribute.sh

clean:
	rm -rf *.kubeconfig
	rm -rf generated