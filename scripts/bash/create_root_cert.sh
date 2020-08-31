# Script for creating a root certificate (and adding it to the trusted certificate store on MacOS)
# Kudos to https://deliciousbrains.com/ssl-certificate-authority-for-local-https-development/

openssl genrsa -des3 -out myCA.key 2048

openssl req -x509 -new -nodes -key myCA.key -sha256 -days 1825 -out myCA.pem

sudo security add-trusted-cert -d -r trustRoot -k "/Library/Keychains/System.keychain" myCA.pem