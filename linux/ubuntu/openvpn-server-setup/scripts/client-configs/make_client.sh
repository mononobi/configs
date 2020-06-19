#!/bin/bash

# First argument: Client identifier
    
cd ~/easy-rsa

./easyrsa gen-req ${1} nopass

cp ~/easy-rsa/pki/private/${1}.key ~/client-configs/keys/

./easyrsa sign-req client ${1}

cp ~/easy-rsa/pki/issued/${1}.crt ~/client-configs/keys/

cd ~/client-configs/

./make_config.sh ${1}

./make_config_tcp.sh ${1}
