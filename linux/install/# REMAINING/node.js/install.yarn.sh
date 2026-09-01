#!/bin/bash

############ you must first install node and npm ############

keyring='/usr/share/keyrings'
yarn_site='https://dl.yarnpkg.com/debian'
yarn_key_url="$yarn_site/pubkey.gpg"
local_yarn_key="$keyring/yarnkey.gpg"

curl -sL $yarn_key_url | gpg --dearmor | sudo tee $local_yarn_key >/dev/null
echo "deb [signed-by=$local_yarn_key] $yarn_site stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
sudo apt-get update && sudo apt-get install yarn
