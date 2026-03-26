@echo off
:: Copyright 2026 HCL Technologies
::
:: Licensed under the Apache License, Version 2.0 (the "License");
:: you may not use this file except in compliance with the License.
:: You may obtain a copy of the License at
::
::     http://www.apache.org/licenses/LICENSE-2.0
::
:: Unless required by applicable law or agreed to in writing, software
:: distributed under the License is distributed on an "AS IS" BASIS,
:: WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
:: See the License for the specific language governing permissions and
:: limitations under the License.

cd data
if not exist certs md certs
cd ..
echo Creating Root CA for certificates...
call docker run --rm -it -v ./data/certs:/data/certs alpine/openssl:latest genrsa -out ./data/certs/root-ca-key.pem 2048
call docker run --rm -it -v ./data/certs:/data/certs alpine/openssl:latest req -new -x509 -sha256 -key /data/certs/root-ca-key.pem -subj "/C=US/O=ORG/OU=UNIT/CN=opensearch" -out ./data/certs/root-ca.pem -days 730

echo Creating Admin cert for OpenSearch configuration...
call docker run --rm -it -v ./data/certs:/data/certs alpine/openssl:latest genrsa -out ./data/certs/admin-key-temp.pem 2048
call docker run --rm -it -v ./data/certs:/data/certs alpine/openssl:latest pkcs8 -inform PEM -outform PEM -in ./data/certs/admin-key-temp.pem -topk8 -nocrypt -v1 PBE-SHA1-3DES -out ./data/certs/admin-key.pem
call docker run --rm -it -v ./data/certs:/data/certs alpine/openssl:latest req -new -key ./data/certs/admin-key.pem -subj "/C=US/O=ORG/OU=UNIT/CN=A" -out ./data/certs/admin.csr
call docker run --rm -it -v ./data/certs:/data/certs alpine/openssl:latest x509 -req -in ./data/certs/admin.csr -CA ./data/certs/root-ca.pem -CAkey ./data/certs/root-ca-key.pem -CAcreateserial -sha256 -out ./data/certs/admin.pem -days 730

echo Creating Node cert for inter node communication...
call docker run --rm -it -v ./data/certs:/data/certs alpine/openssl:latest genrsa -out ./data/certs/node-key-temp.pem 2048
call docker run --rm -it -v ./data/certs:/data/certs alpine/openssl:latest pkcs8 -inform PEM -outform PEM -in ./data/certs/node-key-temp.pem -topk8 -nocrypt -v1 PBE-SHA1-3DES -out ./data/certs/node-key.pem
call docker run --rm -it -v ./data/certs:/data/certs alpine/openssl:latest req -new -key ./data/certs/node-key.pem -subj "/C=US/O=ORG/OU=UNIT/CN=opensearch-node" -out ./data/certs/node.csr
call docker run --rm -it -v ./data/certs:/data/certs alpine/openssl:latest x509 -req -in ./data/certs/node.csr -CA ./data/certs/root-ca.pem -CAkey ./data/certs/root-ca-key.pem -CAcreateserial -sha256 -out ./data/certs/node.pem -days 730

echo Creating Client cert for application authentication...
call docker run --rm -it -v ./data/certs:/data/certs alpine/openssl:latest genrsa -out ./data/certs/client-key-temp.pem 2048
call docker run --rm -it -v ./data/certs:/data/certs alpine/openssl:latest pkcs8 -inform PEM -outform PEM -in ./data/certs/client-key-temp.pem -topk8 -nocrypt -v1 PBE-SHA1-3DES -out ./data/certs/client-key.pem
call docker run --rm -it -v ./data/certs:/data/certs alpine/openssl:latest req -new -key ./data/certs/client-key.pem -subj "/C=US/O=ORG/OU=UNIT/CN=opensearch-client" -out ./data/certs/client.csr
call docker run --rm -it -v ./data/certs:/data/certs alpine/openssl:latest x509 -req -in ./data/certs/client.csr -CA ./data/certs/root-ca.pem -CAkey ./data/certs/root-ca-key.pem -CAcreateserial -sha256 -out ./data/certs/client.pem -days 730


echo Creating the certificate for HTTPS access
call docker run --rm -it -v ./data/certs:/data/certs alpine/openssl:latest req -x509 -nodes -days 365 -newkey rsa:2048 -keyout ./data/certs/tls.key -out ./data/certs/tls.crt -subj "/CN=test"

