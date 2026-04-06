#!/bin/bash

echo "==================================="
echo "Генерация ключей для Xray Reality"
echo "==================================="
echo ""

read -p "Введите IP адрес Bridge сервера: " BRIDGE_IP
read -p "Введите IP адрес Upstream сервера: " UPSTREAM_IP
echo ""

echo "1. UUID для Bridge клиента:"
BRIDGE_UUID=$(docker run --rm teddysun/xray xray uuid)
echo "$BRIDGE_UUID"
echo ""

echo "2. UUID для Upstream сервера:"
UPSTREAM_UUID=$(docker run --rm teddysun/xray xray uuid)
echo "$UPSTREAM_UUID"
echo ""

echo "3. Reality ключи для Bridge:"
BRIDGE_KEYS=$(docker run --rm teddysun/xray xray x25519)
BRIDGE_PRIVATE=$(echo "$BRIDGE_KEYS" | grep "Private key:" | awk '{print $3}')
BRIDGE_PUBLIC=$(echo "$BRIDGE_KEYS" | grep "Public key:" | awk '{print $3}')
echo "$BRIDGE_KEYS"
echo ""

echo "4. Reality ключи для Upstream:"
UPSTREAM_KEYS=$(docker run --rm teddysun/xray xray x25519)
UPSTREAM_PRIVATE=$(echo "$UPSTREAM_KEYS" | grep "Private key:" | awk '{print $3}')
UPSTREAM_PUBLIC=$(echo "$UPSTREAM_KEYS" | grep "Public key:" | awk '{print $3}')
echo "$UPSTREAM_KEYS"
echo ""

echo "5. Short ID для Bridge:"
BRIDGE_SHORT_ID=$(openssl rand -hex 8)
echo "$BRIDGE_SHORT_ID"
echo ""

echo "6. Short ID для Upstream:"
UPSTREAM_SHORT_ID=$(openssl rand -hex 8)
echo "$UPSTREAM_SHORT_ID"
echo ""


BRIDGE_VLESS="vless://$BRIDGE_UUID@$BRIDGE_IP:13335?encryption=none&security=reality&sni=vk.ru&fp=chrome&pbk=$BRIDGE_PUBLIC&sid=$BRIDGE_SHORT_ID&type=xhttp&path=%2Fapi%2Fv1%2Fdata#Bridge-Reality"
UPSTREAM_VLESS="vless://$UPSTREAM_UUID@$UPSTREAM_IP:13335?encryption=none&security=reality&sni=vk.ru&fp=chrome&pbk=$UPSTREAM_PUBLIC&sid=$UPSTREAM_SHORT_ID&type=xhttp&path=%2Fapi%2Fv1%2Fdata#Upstream-Reality"

echo "Ссылка для подключения к Bridge:"
echo "$BRIDGE_VLESS"
echo ""
echo "Ссылка для подключения к Upstream:"
echo "$UPSTREAM_VLESS"
echo ""

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

BRIDGE_SUB_DIR="$SCRIPT_DIR/bridge/subscription"
mkdir -p "$BRIDGE_SUB_DIR"
echo "$BRIDGE_VLESS" | base64 -w 0 > "$BRIDGE_SUB_DIR/index.html"

UPSTREAM_SUB_DIR="$SCRIPT_DIR/upstream/subscription"
mkdir -p "$UPSTREAM_SUB_DIR"
echo "$UPSTREAM_VLESS" | base64 -w 0 > "$UPSTREAM_SUB_DIR/index.html"

echo "Subscription URLs:"
echo "  Bridge:   http://$BRIDGE_IP:8080/sub"
echo "  Upstream: http://$UPSTREAM_IP:8080/sub"
echo ""

echo "==================================="
echo "Значения для подстановки в конфиги серверов:"
echo "==================================="
echo ""
echo "bridge/config.json:"
echo "  BRIDGE-UUID:        $BRIDGE_UUID"
echo "  BRIDGE-PRIVATE-KEY: $BRIDGE_PRIVATE"
echo "  UPSTREAM-SERVER-IP: $UPSTREAM_IP"
echo "  UPSTREAM-UUID:      $UPSTREAM_UUID"
echo "  UPSTREAM-PASSWORD:  $UPSTREAM_PUBLIC"
echo ""
echo "upstream/config.json:"
echo "  UPSTREAM-UUID:        $UPSTREAM_UUID"
echo "  UPSTREAM-PRIVATE-KEY: $UPSTREAM_PRIVATE"
echo "==================================="
