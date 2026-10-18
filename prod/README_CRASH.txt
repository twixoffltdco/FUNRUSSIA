CrashGuard + EuroSystem fix
============================

ЧТО В ЛОГЕ
----------
Краш НЕ pawn-ошибка (нет "Script[...]), а native crash в samp03svr:
  #8 080a8403 in ./samp03svr
  EAX=0 — типичный null pointer внутри сервера/плагина.

Время: через ~5 сек после последнего дисконнекта игрока.
EuroSystem при этом уже был Loaded OK — прямой вины FS в логе нет.

ЧАСТЫЕ ПРИЧИНЫ НА ТВОЁМ СТЕКЕ
-----------------------------
1) sampvoice.so — в старом логе было: "failed to bind voice server"
2) Таймеры геймода после leave (FAMILY CAR APPLY TUNING спам)
3) Плагины streamer / pawnraknet на cleanup
4) Слишком частые таймеры FS (PlaytimeTick каждую 1 сек) — ослаблено до 30 сек

ЧТО СДЕЛАНО
-----------
EuroSystem.pwn:
- KillTimer джетпака на disconnect
- сброс PlayerLoaded/балансов
- PlaytimeTick раз в 30 сек вместо 1 сек
- защита MemeFlyEnd

CrashGuard.pwn:
- лог disconnect
- watchdog пустого сервера
- трек vehicle id

server.cfg пример:
filterscripts CrashGuard EuroSystem

КАК НАЙТИ ВИНОВНИКА
-------------------
1) Убери ВСЕ filterscripts кроме пустого — краш остаётся? -> геймод/плагин
2) Убери sampvoice из plugins — проверь 30+ мин
3) Не спамь /veh /delveh /flip на краш-тест
4) В crashdetect иногда нужен debug info у .amx (pawn -d3)

ВАЖНО
-----
Filterscript НЕ может на 100% починить краш внутри samp03svr.
Если после CrashGuard+обновлённого Euro краш тот же — отключай
по одному: sampvoice, profiler, потом смотри family car timers в моде.
