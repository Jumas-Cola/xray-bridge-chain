#!/bin/bash

echo "==================================="
echo "Генерация ключей для Xray Reality"
echo "==================================="
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
BRIDGE_PUBLIC=$(echo "$BRIDGE_KEYS" | grep "Password:" | awk '{print $2}')
echo "$BRIDGE_KEYS"
echo ""

echo "4. Reality ключи для Upstream:"
UPSTREAM_KEYS=$(docker run --rm teddysun/xray xray x25519)
UPSTREAM_PRIVATE=$(echo "$UPSTREAM_KEYS" | grep "Private key:" | awk '{print $3}')
UPSTREAM_PUBLIC=$(echo "$UPSTREAM_KEYS" | grep "Password:" | awk '{print $2}')
echo "$UPSTREAM_KEYS"
echo ""

echo "5. Short ID для Bridge (используйте пустую строку \"\" или этот):"
openssl rand -hex 8
echo ""

echo "6. Short ID для Upstream:"
openssl rand -hex 8
echo ""


echo "Ссылка для подключения к Upstream (вставьте UPSTREAM_SERVER_IP):"
echo "vless://$UPSTREAM_UUID@UPSTREAM_SERVER_IP:13335?encryption=none&flow=xtls-rprx-vision&security=reality&sni=gosuslugi.ru&fp=chrome&pbk=$UPSTREAM_PUBLIC&sid=0123456789abcdef&type=tcp&headerType=none#Upstream-Reality"
echo ""

echo "Ссылка для подключения к Bridge (вставьте BRIDGE_SERVER_IP):"
echo "vless://$BRIDGE_UUID@BRIDGE_SERVER_IP:13335?encryption=none&flow=xtls-rprx-vision&security=reality&sni=yandex.ru&fp=chrome&pbk=$BRIDGE_PUBLIC&sid=0123456789abcdef&type=tcp#Bridge-Yandex"
echo ""



echo "==================================="
echo "Сохраните эти значения!"
echo "==================================="
