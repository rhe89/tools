# Script for creating a CA-Signed Certificate. (use create_root_cert.sh to create the root certificate needed here).
# Kudos to https://deliciousbrains.com/ssl-certificate-authority-for-local-https-development/

#!/bin/sh

if [ "$#" -ne 1 ]
then
  echo "Usage: Must supply a domain"
  exit 1
fi

DOMAIN=$1

cd ~/certs

openssl genrsa -out $DOMAIN.key 2048
openssl req -new -key $DOMAIN.key -out $DOMAIN.csr

cat > $DOMAIN.ext << EOF
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
subjectAltName = @alt_names
[alt_names]
DNS.1 = $DOMAIN
EOF

openssl x509 -req -in $DOMAIN.csr -CA myCA.pem -CAkey myCA.key -CAcreateserial -out $DOMAIN.crt -days 825 -sha256 -extfile $DOMAIN.ext

openssl pkcs12 -export -out $DOMAIN.pfx -inkey $DOMAIN.key -in $DOMAIN.crt
