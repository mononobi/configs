#!/bin/bash

# IMPORTANT:
# This is the legacy way of doing it and might not work.

# if you have already installed yarn and the yarn key has been expired
# and you faced errors during apt update, execute this to get the new key.

keyring='/usr/share/keyrings'
yarn_site='https://dl.yarnpkg.com/debian'
yarn_key_url="$yarn_site/pubkey.gpg"
local_yarn_key="$keyring/yarnkey.gpg"

curl -sL $yarn_key_url | gpg --dearmor | sudo tee $local_yarn_key >/dev/null
