#!/bin/sh

# When we get killed, kill all our children
trap "exit" INT TERM
trap "kill 0" EXIT

# Source in util.sh so we can have our nice tools
. $(cd $(dirname $0); pwd)/util.sh

# Determine Docker bridge IP
docker_bridge_ip=$(docker network inspect bridge | grep Gateway | grep -o -E '[0-9.]+')

# Set dynamic domain names
domain_name=${domain_name:-example.local}
ws_host=${ws_host:$docker_bridge_ip}
ws_port=${ws_port:-80}
sed -i "s/__DOMAIN_NAME__/$domain_name/g" /etc/nginx/conf.d/*.conf
sed -i "s/__WS_HOST__/$ws_host/g" /etc/nginx/conf.d/*.conf
sed -i "s/__WS_PORT__/$ws_port/g" /etc/nginx/conf.d/*.conf

# Immediately run auto_enable_configs so that nginx is in a runnable state
auto_enable_configs

# Start up nginx, save PID so we can reload config inside of run_certbot.sh
nginx -g "daemon off;" &
export NGINX_PID=$!

# Run startup scripts
for f in /scripts/startup/*.sh; do
    if [[ -x "$f" ]]; then
        echo "Running startup script $f"
        $f
    fi
done
echo "Done with startup"

# Next, run certbot to request all the ssl certs we can find
/scripts/run_certbot.sh

# Run `cron -f &` so that it's a background job owned by bash and then `wait`.
# This allows SIGINT (e.g. CTRL-C) to kill cron gracefully, due to our `trap`.
cron -f &
wait "$NGINX_PID"
