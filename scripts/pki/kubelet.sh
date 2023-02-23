gen_conf() {
cat > openssl-kubelet.cnf <<EOF
[req]
req_extensions = v3_req
distinguished_name = req_distinguished_name
[req_distinguished_name]
[v3_req]
basicConstraints = critical, CA:FALSE
keyUsage = critical, nonRepudiation, digitalSignature, keyEncipherment
extendedKeyUsage = clientAuth
EOF
}

gen_cert() {
{
  openssl genrsa -out apiserver-kubelet-client.key 2048

  openssl req -new -key apiserver-kubelet-client.key \
    -subj "/CN=kube-apiserver-kubelet-client/O=system:masters" -out apiserver-kubelet-client.csr -config openssl-kubelet.cnf

  openssl x509 -req -in apiserver-kubelet-client.csr \
  -CA ca.crt -CAkey ca.key -CAcreateserial  -out apiserver-kubelet-client.crt -extensions v3_req -extfile openssl-kubelet.cnf -days 1000
}
}

main() {
    gen_conf
    gen_cert
}

main