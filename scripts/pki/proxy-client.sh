{
  openssl genrsa -out proxy-client.key 2048

  openssl req -new -key proxy-client.key \
    -subj "/CN=system:serviceaccount:kube-system:metrics-server/O=Kubernetes" -out proxy-client.csr

  openssl x509 -req -in proxy-client.csr \
    -CA ca.crt -CAkey ca.key -CAcreateserial  -out proxy-client.crt -days 1000
}
