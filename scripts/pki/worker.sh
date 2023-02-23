WORKER_1=192.168.56.21
WORKER_2=192.168.56.22
{
cat > openssl-worker-1.cnf <<EOF
[req]
req_extensions = v3_req
distinguished_name = req_distinguished_name
[req_distinguished_name]
[ v3_req ]
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
subjectAltName = @alt_names
[alt_names]
DNS.1 = worker-1
IP.1 = ${WORKER_1}
EOF

openssl genrsa -out worker-1.key 2048
openssl req -new -key worker-1.key -subj "/CN=system:node:worker-1/O=system:nodes" -out worker-1.csr -config openssl-worker-1.cnf
openssl x509 -req -in worker-1.csr -CA ca.crt -CAkey ca.key -CAcreateserial  -out worker-1.crt -extensions v3_req -extfile openssl-worker-1.cnf -days 1000
}

{
cat > openssl-worker-2.cnf <<EOF
[req]
req_extensions = v3_req
distinguished_name = req_distinguished_name
[req_distinguished_name]
[ v3_req ]
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
subjectAltName = @alt_names
[alt_names]
DNS.1 = worker-2
IP.1 = ${WORKER_2}
EOF

openssl genrsa -out worker-2.key 2048
openssl req -new -key worker-2.key -subj "/CN=system:node:worker-2/O=system:nodes" -out worker-2.csr -config openssl-worker-2.cnf
openssl x509 -req -in worker-2.csr -CA ca.crt -CAkey ca.key -CAcreateserial  -out worker-2.crt -extensions v3_req -extfile openssl-worker-2.cnf -days 1000
}