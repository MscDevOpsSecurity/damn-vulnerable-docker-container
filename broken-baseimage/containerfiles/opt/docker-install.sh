#!/bin/bash

removeAWSCredentials() {
    export AWS_ACCESS_KEY=OVERRIDE
    export AWS_SECRET_ACCESS_KEY=OVERRIDE
}

#https://www.cyberciti.biz/faq/ubuntu-20-04-set-up-wireguard-vpn-server/
copyWireGuardProfile() {
echo """
[Interface]
  PrivateKey = mPsd+CgO8Nku8eJ6DfUU6N8tUJAjVYCrQK9mHThL3PA=
  Address = 192.168.123.107/32

[Peer]
  PublicKey = EDZp83opRWoMAjk7Zp3bgF5jiu2DjeI8qxgiiD1XWnM=
  AllowedIPs = 192.168.1.0/24
  Endpoint = 52.18.63.80:51820
  PersistentKeepalive = 180
""" > /etc/wireguard/wg0.conf
}

configureWireGuardVPN() {
    mkdir -m 0700 /etc/wireguard/
}

verifyInstall() {
    cat /etc/wireguard/wg0.conf
}

# Install company VPN Profile 
configureWireGuardVPN
copyWireGuardProfile
verifyInstall

# A lousy attempt to remove the credentials :)
removeAWSCredentials