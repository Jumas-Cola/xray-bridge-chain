#!/bin/bash

echo "==================================="
echo "Генерация ключей для Xray Reality"
echo "==================================="
echo ""

echo "1. UUID для Bridge клиента:"
docker run --rm teddysun/xray xray uuid
echo ""

echo "2. UUID для Upstream сервера:"
docker run --rm teddysun/xray xray uuid
echo ""

echo "3. Reality ключи для Bridge:"
docker run --rm teddysun/xray xray x25519
echo ""

echo "4. Reality ключи для Upstream:"
docker run --rm teddysun/xray xray x25519
echo ""

echo "5. Short ID для Bridge (используйте пустую строку \"\" или этот):"
openssl rand -hex 8
echo ""

echo "6. Short ID для Upstream:"
openssl rand -hex 8
echo ""

echo "==================================="
echo "Сохраните эти значения!"
echo "==================================="
