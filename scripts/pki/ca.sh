{
  # Create private key for CA
  openssl genrsa -out ca.key 2048

  # Comment line starting with RANDFILE in /etc/ssl/openssl.cnf definition to avoid permission issues
  # sudo sed -i '0,/RANDFILE/{s/RANDFILE/\#&/}' /etc/ssl/openssl.cnf

  # Create CSR using the private key
  openssl req -new -key ca.key -subj "/CN=KUBERNETES-CA/O=Kubernetes" -out ca.csr

  # Self sign the csr using its own private key
  openssl x509 -req -in ca.csr -signkey ca.key -CAcreateserial  -out ca.crt -days 1000
}
