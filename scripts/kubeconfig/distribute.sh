{
for instance in master-1 master-2; do
   files=(admin.kubeconfig kube-controller-manager.kubeconfig kube-scheduler.kubeconfig)

    for file in "${files[@]}"; do
        cp generated/${file} generated/kubeconfig-master/
    done

    vagrant scp generated/kubeconfig-master/ ${instance}:~/
done

for instance in worker-1 worker-2 ; do
    files=(kube-proxy.kubeconfig worker-1.kubeconfig worker-2.kubeconfig)

    for file in "${files[@]}"; do
        cp generated/${file} generated/kubeconfig-worker/
    done

    vagrant scp generated/kubeconfig-worker/ ${instance}:~/
done
}
