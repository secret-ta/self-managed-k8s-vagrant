{
for instance in master-1 master-2; do
   files=(ca.crt ca.key kube-apiserver.key
     kube-apiserver.crt apiserver-kubelet-client.crt apiserver-kubelet-client.key service-account.key 
     service-account.crt etcd-server.key etcd-server.crt kube-controller-manager.key kube-controller-manager.crt 
     kube-scheduler.key kube-scheduler.crt ca-proxy.crt proxy-client.crt proxy-client.key)

    for file in "${files[@]}"; do
        cp generated/${file} generated/certs-master/
    done

    vagrant scp generated/certs-master/ ${instance}:~/
done

for instance in worker-1 worker-2 ; do
    files=(ca.crt kube-proxy.crt kube-proxy.key worker-1.crt worker-1.key worker-2.crt worker-2.key)

    for file in "${files[@]}"; do
        cp generated/${file} generated/certs-worker/
    done

    vagrant scp generated/certs-worker/ ${instance}:~/
done
}