# Ansible Playbook for Xray Bridge Chain

Этот каталог содержит Ansible playbook для автоматического деплоя Xray Bridge Chain (upstream и bridge серверы).

## Структура

```
ansible/
├── inventory/
│   └── hosts.yml          # Инвентарь серверов
├── group_vars/
│   ├── all.yml            # Общие переменные
│   ├── upstream.yml       # Переменные для upstream сервера
│   └── bridge.yml         # Переменные для bridge сервера (будет создан позже)
├── tasks/
│   ├── generate_keys.yml  # Генерация ключей Xray
│   ├── warp_registration.yml  # Регистрация WARP
│   └── deploy.yml         # Деплой сервисов
├── templates/
│   ├── upstream_config.json.j2
│   ├── upstream_docker-compose.yml.j2
│   └── upstream_env.j2
├── upstream.yml           # Playbook для upstream сервера
└── bridge.yml             # Playbook для bridge сервера (будет создан позже)
```

## Настройка

1. Отредактируйте `inventory/hosts.yml`, указав реальные IP-адреса серверов:
   ```yaml
   upstream:
     hosts:
       upstream-server:
         ansible_host: "123.456.789.0"  # Ваш IP
         ansible_user: root
   ```

2. При необходимости измените переменные в `group_vars/upstream.yml`

## Использование

### Деплой Upstream сервера

```bash
cd ansible
ansible-playbook -i inventory/hosts.yml upstream.yml
```

### Что делает playbook:

1. **Генерация ключей**: Автоматически генерирует UUID, Reality ключи и Short ID
2. **Регистрация WARP**: Скачивает `warp-reg` и регистрирует WireGuard аккаунт
3. **Установка Docker**: Устанавливает Docker и docker-compose plugin
4. **Создание конфигов**: Генерирует `config.json`, `docker-compose.yml` и `.env`
5. **Запуск**: Запускает контейнер через `docker compose up -d`
6. **Вывод ссылки**: Показывает готовую ссылку для подключения

## Требования

- Серверы с Ubuntu/Debian
- SSH доступ с правами root
- Ansible на локальной машине

## Примечания

- WARP ключи сохраняются в `/opt/xray-upstream/warp_keys.json` на сервере
- При повторном запуске playbook WARP не будет регистрироваться заново (если файл ключей существует)
- Xray ключи генерируются каждый раз заново при запуске playbook
