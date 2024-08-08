#!/bin/sh

if [ "$#" -ne 3 ]; then
  echo "Usage: Must supply a domain and certificate name & ip address. Example: ./cert.sh domain.lan myCA 192.168.1.x"
  exit 1
fi

DOMAIN=$1
CANAME=$2
IPADDR=$3

echo "Generating CA key..."
winpty OPENSSL genrsa -des3 -out $CANAME.key 2048

echo "Generating CA certificate..."
winpty OPENSSL req -x509 -new -nodes -key $CANAME.key -sha256 -days 1825 -out $CANAME.pem

echo "Generating domain key..."
winpty OPENSSL genrsa -out $DOMAIN.key 2048

echo "Generating domain CSR..."
winpty OPENSSL req -new -key $DOMAIN.key -out $DOMAIN.csr

echo "Creating domain extension file..."
cat > $DOMAIN.ext << EOF
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
subjectAltName = @alt_names
[alt_names]
IP.1 = ${IPADDR}
EOF

echo "Generating domain certificate..."
winpty OPENSSL x509 -req -in $DOMAIN.csr -CA $CANAME.pem -CAkey $CANAME.key -CAcreateserial -out $DOMAIN.crt -days 825 -sha256 -extfile $DOMAIN.ext

echo "Certificate generation completed."
