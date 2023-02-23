LOADBALANCER=192.168.56.30


{
    kubectl config set-cluster kubernetes-the-hard-way \
    --certificate-authority=../pki/generated/ca.crt \
    --embed-certs=true \
    --server=https://${LOADBALANCER}:6443

    kubectl config set-credentials admin \
    --client-certificate=../pki/generated/admin.crt \
    --client-key=../pki/generated/admin.key

    kubectl config set-context kubernetes-the-hard-way \
    --cluster=kubernetes-the-hard-way \
    --user=admin

    kubectl config use-context kubernetes-the-hard-way
}
