#!/bin/sh

domain_name=${domain_name:-example.local}
ws_host=${ws_host:-172.17.0.1}
ws_port=${ws_port:-80}

sed -i "s/__DOMAIN_NAME__/$domain_name/g" /etc/nginx/conf.d/*.conf
sed -i "s/__WS_HOST__/$ws_host/g" /etc/nginx/conf.d/*.conf
sed -i "s/__WS_PORT__/$ws_port/g" /etc/nginx/conf.d/*.conf
