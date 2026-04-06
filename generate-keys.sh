#!/bin/bash

read -rp "Bridge server IP: " BRIDGE_SERVER_IP
read -rp "Upstream server IP: " UPSTREAM_SERVER_IP

BRIDGE_UUID=$(docker run --rm teddysun/xray xray uuid)
UPSTREAM_UUID=$(docker run --rm teddysun/xray xray uuid)

BRIDGE_KEYS=$(docker run --rm teddysun/xray xray x25519)
BRIDGE_PRIVATE=$(echo "$BRIDGE_KEYS" | grep "Private key:" | awk '{print $3}')
BRIDGE_PUBLIC=$(echo "$BRIDGE_KEYS" | grep "Public key:" | awk '{print $3}')

UPSTREAM_KEYS=$(docker run --rm teddysun/xray xray x25519)
UPSTREAM_PRIVATE=$(echo "$UPSTREAM_KEYS" | grep "Private key:" | awk '{print $3}')
UPSTREAM_PUBLIC=$(echo "$UPSTREAM_KEYS" | grep "Public key:" | awk '{print $3}')

ROUTING_BLOCK=$(cat <<'ROUTING'
    "routing": {
        "domainStrategy": "IPIfNonMatch",
        "rules": [
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
                "ip": [
                    "geoip:ru",
                    "geoip:private"
                ],
                "outboundTag": "direct"
            }
        ]
    },
ROUTING
)

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
    "inbounds": [
        {
            "port": 10808,
            "protocol": "socks",
            "settings": {
                "auth": "noauth",
                "udp": true
            }
        },
        {
            "port": 10809,
            "protocol": "http",
            "settings": {}
        }
    ],
$ROUTING_BLOCK
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
                                "encryption": "none"
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
                    "shortId": "0123456789abcdef"
                },
                "xhttpSettings": {
                    "path": "/api/v1/data",
                    "mode": "auto",
                    "extra": {
                        "xPaddingBytes": "100-1000"
                    }
                }
            }
        },
        {
            "tag": "direct",
            "protocol": "freedom",
            "settings": {}
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
