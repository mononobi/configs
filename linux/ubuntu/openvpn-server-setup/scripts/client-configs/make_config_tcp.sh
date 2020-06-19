#!/bin/bash

# First argument: Client identifier

EASYRSA_DIR=~/easy-rsa
CA_DIR=~/easy-rsa/pki
KEY_DIR=~/client-configs/keys
OUTPUT_DIR=~/client-configs/files
BASE_CONFIG=~/client-configs/base.tcp.conf

cat ${BASE_CONFIG} \
    <(echo -e '<ca>') \
    ${CA_DIR}/ca.crt \
    <(echo -e '</ca>\n<cert>') \
    ${KEY_DIR}/${1}.crt \
    <(echo -e '</cert>\n<key>') \
    ${KEY_DIR}/${1}.key \
    <(echo -e '</key>\n<tls-crypt>') \
    ${EASYRSA_DIR}/ta.key \
    <(echo -e '</tls-crypt>') \
    > ${OUTPUT_DIR}/${1}.tcp.ovpn
