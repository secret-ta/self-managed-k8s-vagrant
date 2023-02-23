gen_conf() {
cat > openssl-etcd.cnf <<EOF
[req]
req_extensions = v3_req
distinguished_name = req_distinguished_name
[req_distinguished_name]
[ v3_req ]
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
subjectAltName = @alt_names
[alt_names]
IP.1 = ${MASTER_1}
IP.2 = ${MASTER_2}
IP.3 = 127.0.0.1
EOF
}

gen_cert() {
{
  openssl genrsa -out etcd-server.key 2048

  openssl req -new -key etcd-server.key \
    -subj "/CN=etcd-server/O=Kubernetes" -out etcd-server.csr -config openssl-etcd.cnf

  openssl x509 -req -in etcd-server.csr \
    -CA ca.crt -CAkey ca.key -CAcreateserial  -out etcd-server.crt -extensions v3_req -extfile openssl-etcd.cnf -days 1000
}
}

main() {
    gen_conf
    gen_cert
}

export MASTER_1=192.168.56.11
export MASTER_2=192.168.56.12
main