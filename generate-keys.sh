#!/bin/bash

read -rp "Bridge server IP: " BRIDGE_SERVER_IP
read -rp "Upstream server IP: " UPSTREAM_SERVER_IP

BRIDGE_UUID_F=$(mktemp)
UPSTREAM_UUID_F=$(mktemp)
BRIDGE_KEYS_F=$(mktemp)
UPSTREAM_KEYS_F=$(mktemp)

docker run --rm teddysun/xray xray uuid    > "$BRIDGE_UUID_F"   &
docker run --rm teddysun/xray xray uuid    > "$UPSTREAM_UUID_F" &
docker run --rm teddysun/xray xray x25519  > "$BRIDGE_KEYS_F"   &
docker run --rm teddysun/xray xray x25519  > "$UPSTREAM_KEYS_F" &
wait

BRIDGE_UUID=$(cat "$BRIDGE_UUID_F")
UPSTREAM_UUID=$(cat "$UPSTREAM_UUID_F")
BRIDGE_PUBLIC=$(grep "Public key:" "$BRIDGE_KEYS_F" | awk '{print $3}')
UPSTREAM_PUBLIC=$(grep "Public key:" "$UPSTREAM_KEYS_F" | awk '{print $3}')

rm -f "$BRIDGE_UUID_F" "$UPSTREAM_UUID_F" "$BRIDGE_KEYS_F" "$UPSTREAM_KEYS_F"

generate_client_config() {
    local server_ip="$1"
    local uuid="$2"
    local pubkey="$3"
    local output_file="$4"

    cat > "$output_file" <<EOF
{
    "log": {
        "loglevel": "warning"
    },
    "dns": {
        "servers": [
            "1.1.1.1",
            {
                "address": "223.5.5.5",
                "domains": [
                    "geosite:category-ru"
                ],
                "skipFallback": true,
                "tag": "domestic-dns"
            }
        ],
        "tag": "dns-module"
    },
    "inbounds": [
        {
            "listen": "127.0.0.1",
            "port": 10808,
            "protocol": "socks",
            "settings": {
                "auth": "noauth",
                "udp": true,
                "userLevel": 8
            },
            "sniffing": {
                "destOverride": [
                    "http",
                    "tls"
                ],
                "enabled": true,
                "routeOnly": false
            },
            "tag": "socks"
        },
        {
            "listen": "127.0.0.1",
            "port": 10809,
            "protocol": "http",
            "settings": {
                "userLevel": 8
            },
            "sniffing": {
                "destOverride": [
                    "http",
                    "tls"
                ],
                "enabled": true,
                "routeOnly": false
            },
            "tag": "http"
        }
    ],
    "routing": {
        "domainStrategy": "IPOnDemand",
        "rules": [
            {
                "type": "field",
                "protocol": ["bittorrent"],
                "outboundTag": "direct"
            },
            {
                "type": "field",
                "network": "udp",
                "port": "443",
                "outboundTag": "block"
            },
            {
                "type": "field",
                "ip": ["geoip:private"],
                "outboundTag": "direct"
            },
            {
                "type": "field",
                "domain": ["geosite:private"],
                "outboundTag": "direct"
            },
            {
                "type": "field",
                "domain": [
                    "geosite:category-ru",
                    "domain:ru",
                    "domain:su",
                    "domain:xn--p1acf"
                ],
                "outboundTag": "direct"
            },
            {
                "type": "field",
                "ip": ["geoip:ru"],
                "outboundTag": "direct"
            },
            {
                "type": "field",
                "inboundTag": ["domestic-dns"],
                "outboundTag": "direct"
            },
            {
                "type": "field",
                "inboundTag": ["dns-module"],
                "outboundTag": "proxy"
            }
        ]
    },
    "outbounds": [
        {
            "tag": "proxy",
            "protocol": "vless",
            "settings": {
                "vnext": [
                    {
                        "address": "$server_ip",
                        "port": 13335,
                        "users": [
                            {
                                "id": "$uuid",
                                "encryption": "none",
                                "level": 8
                            }
                        ]
                    }
                ]
            },
            "streamSettings": {
                "network": "xhttp",
                "security": "reality",
                "realitySettings": {
                    "serverName": "vk.ru",
                    "fingerprint": "chrome",
                    "publicKey": "$pubkey",
                    "shortId": "0123456789abcdef",
                    "show": false
                },
                "xhttpSettings": {
                    "path": "/api/v1/data",
                    "mode": "auto"
                }
            },
            "mux": {
                "enabled": false,
                "concurrency": -1
            }
        },
        {
            "tag": "direct",
            "protocol": "freedom",
            "settings": {
                "domainStrategy": "UseIP"
            }
        },
        {
            "tag": "block",
            "protocol": "blackhole",
            "settings": {
                "response": {
                    "type": "http"
                }
            }
        }
    ]
}
EOF
    cat "$output_file"
}

echo ""
echo "=== client-bridge.json ==="
generate_client_config "$BRIDGE_SERVER_IP" "$BRIDGE_UUID" "$BRIDGE_PUBLIC" "client-bridge.json"

echo ""
echo "=== client-upstream.json ==="
generate_client_config "$UPSTREAM_SERVER_IP" "$UPSTREAM_UUID" "$UPSTREAM_PUBLIC" "client-upstream.json"
