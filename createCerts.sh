#!/bin/bash

# Copyright 2024 HCL Technologies
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

rm -rf ./data/certs || true
mkdir -p ./data/certs

# Root CA for certificates
openssl genrsa -out ./data/certs/root-ca-key.pem 2048
openssl req -new -x509 -sha256 -key ./data/certs/root-ca-key.pem -subj "/C=US/O=ORG/OU=UNIT/CN=opensearch" -out ./data/certs/root-ca.pem -days 730

# Admin cert for OpenSearch configuration
openssl genrsa -out ./data/certs/admin-key-temp.pem 2048
openssl pkcs8 -inform PEM -outform PEM -in ./data/certs/admin-key-temp.pem -topk8 -nocrypt -v1 PBE-SHA1-3DES -out ./data/certs/admin-key.pem
openssl req -new -key ./data/certs/admin-key.pem -subj "/C=US/O=ORG/OU=UNIT/CN=A" -out ./data/certs/admin.csr
openssl x509 -req -in ./data/certs/admin.csr -CA ./data/certs/root-ca.pem -CAkey ./data/certs/root-ca-key.pem -CAcreateserial -sha256 -out ./data/certs/admin.pem -days 730

# Node cert for inter node communication
openssl genrsa -out ./data/certs/node-key-temp.pem 2048
openssl pkcs8 -inform PEM -outform PEM -in ./data/certs/node-key-temp.pem -topk8 -nocrypt -v1 PBE-SHA1-3DES -out ./data/certs/node-key.pem
openssl req -new -key ./data/certs/node-key.pem -subj "/C=US/O=ORG/OU=UNIT/CN=opensearch-node" -out ./data/certs/node.csr
openssl x509 -req -in ./data/certs/node.csr -CA ./data/certs/root-ca.pem -CAkey ./data/certs/root-ca-key.pem -CAcreateserial -sha256 -out ./data/certs/node.pem -days 730

# Client cert for application authentication
openssl genrsa -out ./data/certs/client-key-temp.pem 2048
openssl pkcs8 -inform PEM -outform PEM -in ./data/certs/client-key-temp.pem -topk8 -nocrypt -v1 PBE-SHA1-3DES -out ./data/certs/client-key.pem
openssl req -new -key ./data/certs/client-key.pem -subj "/C=US/O=ORG/OU=UNIT/CN=opensearch-client" -out ./data/certs/client.csr
openssl x509 -req -in ./data/certs/client.csr -CA ./data/certs/root-ca.pem -CAkey ./data/certs/root-ca-key.pem -CAcreateserial -sha256 -out ./data/certs/client.pem -days 730


# Creates the certificate for HTTPS access
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout ./data/certs/tls.key -out ./data/certs/tls.crt -subj "/CN=test"

# Let anyone read the certs
chmod +r ./data/certs/*
