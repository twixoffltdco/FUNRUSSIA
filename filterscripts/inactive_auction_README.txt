========================================
  НЕАКТИВ = ДОМ / БИЗНЕС / ГАРАЖ
========================================

Без команд. Всё работает само.

Если игрок не заходил 2 дня:
  - дом     -> государство (owner_id = 0)
  - бизнес  -> государство (owner_id = 0)
  - гараж   -> государство (owner_id = 0)

Проверка: каждые 30 минут + через 1 мин после старта.

Таблицы: houses, business, garages, accounts

Установка:
  1. Скомпилируй inactive_auction.pwn
  2. server.cfg -> filterscripts inactive_auction
  3. plugin mysql
  4. bykranin_mysql_settings.ini

Лог: scriptfiles/inactive_auction.log
