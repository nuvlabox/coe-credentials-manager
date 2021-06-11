#!/bin/sh

kubectl proxy

HOSTNAME=${HOST:-`hostname`}

openssl genrsa -out nuvlabox.key 4096

cat>nuvlabox.cnf <<EOF
[ req ]
default_bits = 2048
prompt = no
default_md = sha256
distinguished_name = dn
[ dn ]
CN = ${HOSTNAME}
O = sixsq
[ v3_ext ]
authorityKeyIdentifier=keyid,issuer:always
basicConstraints=CA:FALSE
keyUsage=keyEncipherment,dataEncipherment
extendedKeyUsage=serverAuth,clientAuth
EOF

openssl req -config ./nuvlabox.cnf -new -key nuvlabox.key -nodes -out nuvlabox.csr

BASE64_CSR=$(cat ./nuvlabox.csr | base64 | tr -d '\n')

cat>nuvlabox-csr.yaml <<EOF
apiVersion: certificates.k8s.io/v1
kind: CertificateSigningRequest
metadata:
  name: nuvlabox-csr
spec:
  groups:
  - system:authenticated
  request: ${BASE64_CSR}
  signerName: kubernetes.io/kube-apiserver-client
  usages:
  - digital signature
  - key encipherment
  - client auth
EOF

kubectl apply -f nuvlabox-csr.yaml

kubectl certificate approve nuvlabox-csr

kubectl get csr

kubectl get csr nuvlabox-csr -o jsonpath='{.status.certificate}' | base64 -d > nuvlabox.crt

cp nuvlabox.crt nuvlabox.key /var/run/secrets/kubernetes.io/serviceaccount/ca.crt /srv/nuvlabox/shared