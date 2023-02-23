for csr in $(kubectl get csr --kubeconfig kubeconfig-master/admin.kubeconfig | grep -i pending | awk '{ print $1 }'); do
    kubectl certificate approve $csr --kubeconfig kubeconfig-master/admin.kubeconfig
done
