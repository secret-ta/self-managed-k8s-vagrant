{
  # Create private key for CA
  openssl genrsa -out ca-proxy.key 2048

  # Comment line starting with RANDFILE in /etc/ssl/openssl.cnf definition to avoid permission issues
  # sudo sed -i '0,/RANDFILE/{s/RANDFILE/\#&/}' /etc/ssl/openssl.cnf

  # Create CSR using the private key
  openssl req -new -key ca-proxy.key -subj "/CN=KUBERNETES-CA-PROXY/O=Kubernetes" -out ca-proxy.csr

  # Self sign the csr using its own private key
  openssl x509 -req -in ca-proxy.csr -signkey ca-proxy.key -CAcreateserial  -out ca-proxy.crt -days 1000
}
