## Популярные российские домены для маскировки:
### Для Bridge сервера (dest + serverNames):

- www.sberbank.ru - Сбербанк
- www.vk.com - ВКонтакте
- yandex.ru - Яндекс
- mail.ru - Mail.ru
- www.tinkoff.ru - Тинькофф
- www.ozon.ru - Озон
- www.wildberries.ru - Wildberries

### Для Upstream сервера:

- gosuslugi.ru - Госуслуги
- www.mos.ru - Мос.ру
- www.nalog.gov.ru - ФНС
- www.pfr.gov.ru - ПФР


### Важные замечания:

- Выбор домена для dest: Должен поддерживать TLS 1.3 и HTTP/2. Проверьте:

```bash
curl -I --tlsv1.3 --http2 https://www.sberbank.ru
```

- serverNames: Может содержать несколько доменов, клиент выбирает один случайно.
