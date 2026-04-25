#!/bin/bash

echo "==================================="
echo "Генерация ключей для Xray Reality"
echo "==================================="
echo ""

read -p "Введите IP адрес Bridge сервера: " BRIDGE_IP
read -p "Введите IP адрес Upstream сервера: " UPSTREAM_IP
echo ""

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

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
BRIDGE_PRIVATE=$(echo "$BRIDGE_KEYS" | grep "PrivateKey:" | awk '{print $2}')
BRIDGE_PUBLIC=$(echo "$BRIDGE_KEYS" | grep "Password" | awk -F': ' '{print $2}')
echo "$BRIDGE_KEYS"
echo ""

echo "4. Reality ключи для Upstream:"
UPSTREAM_KEYS=$(docker run --rm teddysun/xray xray x25519)
UPSTREAM_PRIVATE=$(echo "$UPSTREAM_KEYS" | grep "PrivateKey:" | awk '{print $2}')
UPSTREAM_PUBLIC=$(echo "$UPSTREAM_KEYS" | grep "Password" | awk -F': ' '{print $2}')
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

echo "==================================="
echo "Подстановка значений в конфиги..."
echo "==================================="
echo ""

sed -i \
    -e "s|BRIDGE-UUID|$BRIDGE_UUID|g" \
    -e "s|BRIDGE-PRIVATE-KEY|$BRIDGE_PRIVATE|g" \
    -e "s|BRIDGE-SHORT-ID|$BRIDGE_SHORT_ID|g" \
    -e "s|UPSTREAM-SERVER-IP|$UPSTREAM_IP|g" \
    -e "s|UPSTREAM-UUID|$UPSTREAM_UUID|g" \
    -e "s|UPSTREAM-PASSWORD|$UPSTREAM_PUBLIC|g" \
    -e "s|UPSTREAM-SHORT-ID|$UPSTREAM_SHORT_ID|g" \
    "$SCRIPT_DIR/bridge/config.json"
echo "bridge/config.json - готово"

sed -i \
    -e "s|UPSTREAM-UUID|$UPSTREAM_UUID|g" \
    -e "s|UPSTREAM-PRIVATE-KEY|$UPSTREAM_PRIVATE|g" \
    -e "s|UPSTREAM-SHORT-ID|$UPSTREAM_SHORT_ID|g" \
    "$SCRIPT_DIR/upstream/config.json"
echo "upstream/config.json - готово"

echo ""
echo "==================================="
echo "Ссылки для подключения:"
echo "==================================="
echo ""

echo "Bridge:"
echo "vless://$BRIDGE_UUID@$BRIDGE_IP:13335?encryption=none&security=reality&sni=google.com&fp=chrome&pbk=$BRIDGE_PUBLIC&sid=$BRIDGE_SHORT_ID&type=xhttp&path=%2Fcdn%2Fassets%2Fmain.min.js#Bridge-Reality"
echo ""

echo "Upstream:"
echo "vless://$UPSTREAM_UUID@$UPSTREAM_IP:13335?encryption=none&security=reality&sni=microsoft.com&fp=chrome&pbk=$UPSTREAM_PUBLIC&sid=$UPSTREAM_SHORT_ID&type=xhttp&path=%2Fcdn%2Fassets%2Fmain.min.js#Upstream-Reality"
echo ""

echo "==================================="
echo "Готово! Конфиги обновлены, можно запускать docker compose up -d"
echo "==================================="
