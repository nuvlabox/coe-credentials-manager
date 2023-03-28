#!/bin/sh -xe

WAIT_APPROVED=${WAIT_APPROVED:-600}

SHARED="/srv/nuvlaedge/shared"
SYNC_FILE=".tls"
CA="/var/run/secrets/kubernetes.io/serviceaccount/ca.crt"
export CSR_NAME="nuvlaedge-csr"
USER="nuvla"

if [ ! -f ${CA} ]
then
  echo "ERR: cannot find CA certificate at ${CA}. Make sure a proper Service Account is being used"
  exit 1
else
  cp ${CA} ca.pem
fi

is_cred_valid() {
  CRED_PATH=${1}

  echo "INFO: md5 of certificate:"
  openssl x509 -noout -modulus -in ${CRED_PATH}/cert.pem | openssl md5
  echo "INFO: md5 of private key:"
  openssl rsa -noout -modulus -in ${CRED_PATH}/key.pem | openssl md5

  curl -f https://${KUBERNETES_SERVICE_HOST}/api \
    --cacert ${CRED_PATH}/ca.pem \
    --cert ${CRED_PATH}/cert.pem  \
    --key ${CRED_PATH}/key.pem
  if [ $? -ne 0 ]
  then
    return 1
  else
    return 0
  fi
}

generate_credentials() {
  echo "INFO: generating new user '${USER}' and API access certificates"

  openssl genrsa -out key.pem 4096

  cat>nuvlaedge.cnf <<EOF
[ req ]
default_bits = 4096
prompt = no
default_md = sha256
distinguished_name = dn
[ dn ]
CN = ${USER}
O = sixsq
[ v3_ext ]
authorityKeyIdentifier=keyid,issuer:always
basicConstraints=CA:FALSE
keyUsage=keyEncipherment,dataEncipherment
extendedKeyUsage=serverAuth,clientAuth
EOF

  openssl req -config ./nuvlaedge.cnf -new -key key.pem -out nuvlaedge.csr

  BASE64_CSR=$(cat ./nuvlaedge.csr | base64 | tr -d '\n')

  cat>nuvlaedge-csr.yaml <<EOF
apiVersion: certificates.k8s.io/v1
kind: CertificateSigningRequest
metadata:
  name: ${CSR_NAME}
  labels:
    nuvlaedge.component: "True"
    nuvlaedge.deployment: "production"
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

  kubectl apply -f nuvlaedge-csr.yaml

  kubectl get csr

  timeout -t ${WAIT_APPROVED} sh -c 'while [[ -z "$CERT" ]]
do
CERT=`kubectl get csr ${CSR_NAME} -o jsonpath="{.status.certificate}" | base64 -d`
done'
  kubectl get csr ${CSR_NAME} -o jsonpath="{.status.certificate}" | base64 -d > cert.pem

  echo "INFO: Validating credentials"

  if is_cred_valid .
  then
    cp ca.pem cert.pem key.pem ${SHARED}
    touch ${SHARED}/${SYNC_FILE}
    echo "INFO: success"
  else
    echo "ERROR: generated credentials are not valid"
    return 1
  fi

  echo "INFO: assigning cluster-admin privileges to user '${USER}'"

  cat>nuvla-cluster-role-binding.yaml <<EOF
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
 name: ${USER}-cluster-role-binding
 labels:
    nuvlaedge.component: "True"
    nuvlaedge.deployment: "production"
subjects:
- kind: User
  name: ${USER}
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: ClusterRole
  name: cluster-admin
  apiGroup: rbac.authorization.k8s.io
EOF

  kubectl apply -f nuvla-cluster-role-binding.yaml
}

############

if [ ! -f ${SHARED}/${SYNC_FILE} ]
then
  generate_credentials
else
  if is_crec_valid ${SHARED}
    echo "INFO: Reusing existing certificates from ${SHARED}: \n$(ls ${SHARED}/*pem)"
  then
    echo "ERR: Existing certificates are not valid. Generating new ones."
    rm ${SHARED}/${SYNC_FILE}
    generate_credentials
  fi
fi
