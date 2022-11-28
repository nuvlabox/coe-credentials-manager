#!/bin/sh -xe

kubectl proxy &

SHARED="/srv/nuvlaedge/shared"
SYNC_FILE=".tls"
CA="/var/run/secrets/kubernetes.io/serviceaccount/ca.crt"
export CSR_NAME="nuvlaedge-csr"
USER="nuvla"

if [[ ! -f ${CA} ]]
then
  echo "ERR: cannot find CA certificate at ${CA}. Make sure a proper Service Account is being used"
  exit 1
fi

generate_credentials() {
  echo "INFO: generating new user '${USER}' and API access certificates"

  openssl genrsa -out key.pem 4096

  cat>nuvlaedge.cnf <<EOF
[ req ]
default_bits = 2048
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

  openssl req -config ./nuvlaedge.cnf -new -key key.pem -nodes -out nuvlaedge.csr

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

  kubectl certificate approve ${CSR_NAME}

  kubectl get csr

  timeout -t 10 sh -c 'while [[ -z "$CERT" ]]
do
CERT=`kubectl get csr ${CSR_NAME} -o jsonpath="{.status.certificate}" | base64 -d`
done'
  kubectl get csr ${CSR_NAME} -o jsonpath="{.status.certificate}" | base64 -d > cert.pem

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

  echo "INFO: success"

  cp ${CA} ${SHARED}/ca.pem
  cp cert.pem key.pem ${SHARED}
  touch ${SHARED}/${SYNC_FILE}
}

############

if [[ ! -f ${SHARED}/${SYNC_FILE} ]]
then
  generate_credentials
else
  echo "INFO: re-using existing certificates from ${SHARED}: \n$(ls ${SHARED}/*pem)"

  set +e
  curl -f https://${KUBERNETES_SERVICE_HOST}/api --cacert ca.pem  --cert cert.pem  --key key.pem

  if [[ $? -ne 0 ]]
  then
    echo "ERR: existing certificates are not valid. Generating new ones"
    rm ${SHARED}/${SYNC_FILE}
    generate_credentials
  fi
fi
