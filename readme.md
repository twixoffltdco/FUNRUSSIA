# 🇷🇺 FUNRUSSIA | Мод Кранин (Base)

![Status](https://img.shields.io/badge/Status-Ready%20to%20Use-brightgreen)
![Language](https://img.shields.io/badge/Language-Pawn-orange)
![Database](https://img.shields.io/badge/Database-MySQL-blue)
![Platform](https://img.shields.io/badge/Platform-Windows%20%26%20Linux-lightgrey)

> Современная, оптимизированная сборка SA-MP на базе мода Кранин.  
> Скачал → настроил → запустил. Без лишнего мусора.
# 🔥 FUN RUSSIA | Официальный репозиторий мода

> **Проект разработан Twixoff (Кранин).** 
> Полностью открытый исходный код (Open Source). Никаких черных ящиков, никаких скрытых бэкдоров. Только чистая архитектура, оптимизация и уважение к комьюнити.

[![Open Source](https://img.shields.io/badge/Open-Source-brightgreen.svg)](https://gitverse.ru/funrussia/funrussia)
[![SA-MP/MTA](https://img.shields.io/badge/Platform-SA--MP%20%7C%20MTA-blue.svg)]()
[![Версия](https://img.shields.io/badge/Version-2.5-orange.svg)]()

---

## 📌 КЛЮЧЕВЫЕ СИСТЕМЫ МОДА

В отличие от слитых сборок, каждая система здесь прописана с нуля и оптимизирована под высокие нагрузки:

- 🚗 **FamilyCars / FamilyGarage**: Точное сохранение координат и угла поворота (Quaternion) фракционного транспорта. Машина заспавнится ровно там, где её оставил лидер. Ноль провалов под карту.
- ⏳ **inactive_auction**: Умная система очистки и аукциона имущества игроков, не проявлявших активность более 3-х дней. Спасает базу данных от мусора и держит экономику живой.
- 🎙️ **sampvoice Integration**: Встроенный, оптимизированный голосовой чат с минимальной задержкой и корректной обработкой зон слышимости.
- 🎵 **Music & Radio System**: Кастомные плейлисты (`playlist_Custom.ini`, `radio.ini`), работающие напрямую в транспорте без рассинхрона и лагов.
- 🛡️ **Безопасность**: Использование Prepared Statements, защита от SQL-инъекций и строгая валидация всех входящих данных.

---

## 🛠 ТЕХНИЧЕСКИЙ СТЕК

Мы не используем дырявые инклуды 2010 года. Только современные и проверенные решения:
- **Ядро**: PAWN (с поддержкой JIT-компиляции для макс. производительности)
- **База данных**: MySQL (с правильными индексами и оптимизированными запросами)
- **Плагины**: `crashdetect`, `sscanf2`, `streamer`, `pawncmd`, `Pawn.RakNet`, `sampvoice`
- **Хранение данных**: JSON + INI для конфигураций, MySQL для персистентных данных

---

## 🚀 КАК ЗАПУСТИТЬ

1. Убедитесь, что у вас установлен компилятор Pawn с поддержкой JIT.
2. Настройте подключение к базе данных в `scriptfiles/config.ini` (или аналогичном файле).
3. Импортируйте дамп базы данных (если предоставляется).
4. Скомпилируйте мод `funrussia335.pwn` и запустите сервер.

---

## 🤝 СОТРУДНИЧЕСТВО И СВЯЗЬ

Мы строим прозрачный проект и всегда открыты к адекватным предложениям по улучшению кода (Pull Request приветствуются!).

- **Официальный чат игроков (MAX)**: [Присоединиться](https://max.ru/join/69hztKiRPMlPGPuj06SM4tOZsHnhfsSXwW377WLTfcU)
- **Форум и новости**: [Resource World - Twixoff](https://resource-world.ru/members/twixoff)
- **Telegram / VK**: Ссылки в профиле проекта

---
> **Twixoff на MYRN RW:** Код не прощает халтуры. Либо ты строишь качественно, либо твой проект умрет через месяц. Мы выбираем первое.
<div align="center">

# 🇷🇺 FUNRUSSIA (Beta)

### Современная SA-MP сборка на базе мода Кранин

![Status](https://img.shields.io/badge/Status-Production-brightgreen?style=for-the-badge)
![Language](https://img.shields.io/badge/Language-Pawn-orange?style=for-the-badge)
![Database](https://img.shields.io/badge/Database-MySQL-4479A1?style=for-the-badge&logo=mysql&logoColor=white)
![Platform](https://img.shields.io/badge/Platform-Win%20%7C%20Linux-lightgrey?style=for-the-badge)

</div>

## 📜 Лицензия

Оригинальная основа — **мод Кранин**.  
Сборка распространяется «как есть». Используйте, дорабатывайте, запускайте.

> 📎 **Не забудьте прочитать `ВАЖНО.txt` перед первым запуском!**

---

<div align="center">

**Если сборка помогла — поставьте ⭐ репозиторию. Это лучшая благодарность.**

</div>

## ✨ Возможности

- 🛡️ **Античит** — встроенная защита от эксплойтов
- 🎙️ **Голосовой чат** — `sampvoice`, общение без сторонних программ
- 📈 **FakeOnline** — эмуляция онлайна для хостингов (подробнее ниже)
- ⚡ **JIT + Profiler** — максимальная производительность
- 🗄️ **MySQL** — готовые скрипты миграции базы данных
- 🧩 **Современный стек** — `Pawn.CMD`, `sscanf2`, `streamer`, `Pawn.RakNet`, `rustext`

---

## 📋 Требования

| Компонент | Минимум |
|-----------|---------|
| SA-MP Server | 0.3.7 / 0.3DL |
| MySQL | 5.7+ |
| ОС сервера | Windows / Linux |
| Компилятор | Pawn Studio или PAWNO |

---

## ⚙️ Установка

### 1. Скачай файлы

Склонируй репозиторий или скачай архив:

```bash
git clone https://gitverse.ru/twixoff/FUNRUSSIA.git
```

### 2. Настрой базу данных

1. Создай новую базу данных в MySQL.
2. Импортируй `KRANIN_DB_MIGRATION.sql` (при необходимости — `KRANIN_DB_MIGRATION2.sql`).
3. Укажи данные подключения (хост, логин, пароль, имя БД) в исходном коде мода.

### 3. Скомпилируй мод

1. Открой `gamemodes/new.pwn` в Pawn Studio или PAWNO.
2. Нажми `F5`.
3. Убедись, что нет ошибок (Errors = 0).

### 4. Настрой server.cfg

Открой `server.cfg` и проверь строку плагинов:

```ini
gamemode0 new 1
plugins crashdetect mysql pawncmd sscanf streamer sampvoice jit FakeOnline
```

### 5. Запусти сервер

- **Windows:** запусти `samp-server.exe`
- **Linux:** выполни `./samp03svr`

> ⚠️ Перед первым запуском обязательно прочитай файл `ВАЖНО.txt` в корне.

---

## 🖥️ Хостинг (HostGta, MyArena и другие)

> **Если сервер пустует — хостинг может его «усыпить» или понизить в мониторинге.**

На большинстве SA-MP хостингов (HostGta и аналоги) серверы с нулевым онлайном автоматически отправляются в спящий режим, перестают отображаться в списке и фактически «умирают», не успев набрать аудиторию.

**Решение:** в этой сборке уже есть плагин `FakeOnline`.

1. Открой `scriptfiles/fakeonline.ini`.
2. Установи значение_fake-онлайна (рекомендуется **15–30**).
3. Убедись, что `FakeOnline` прописан в `server.cfg`.

Это создаст видимость активности, сервер не уснёт, и реальные игроки будут заходить на «живой» сервер.

---

## 📂 Структура файлов

```text
FUNRUSSIA/
 ├── gamemodes/               # Исходный код мода (.pwn / .amx)
 ├── filterscripts/           # Вспомогательные скрипты
 ├── include/                 # Инклуды и библиотеки
 ├── plugins/                 # Плагины (.dll / .so)
 ├── scriptfiles/             # Конфиги (.json, .ini)
 ├── pawno/                   # Компилятор
 ├── KRANIN_DB_MIGRATION.sql  # Миграция БД
 ├── server.cfg               # Конфигурация сервера
 └── ВАЖНО.txt                # Инструкции (читать обязательно)
```

---

## 🧰 Плагины

| Плагин | Для чего |
|--------|----------|
| `crashdetect` | Логирование крашей и ошибок |
| `mysql` | Работа с базой данных |
| `sscanf2` | Парсинг аргументов команд |
| `streamer` | Динамические объекты, пикапы, маппинг |
| `Pawn.RakNet` | Перехват и отправка пакетов |
| `sampvoice` | Голосовая связь в игре |
| `JIT` | Ускорение выполнения кода |
| `FakeOnline` | Эмуляция онлайна для хостингов |

---

## 📤 Как залить на Gitverse

Если хочешь сделать копию репозитория у себя:

```bash
git init
git branch -M main
git remote add origin https://gitverse.ru/ТВОЙ_ЛОГИН/ТВОЙ_РЕПОЗИТОРИЙ.git
git add .
git commit -m "FUNRUSSIA base"
git push -u origin main
```

При запросе введи логин и пароль от Gitverse.

---

## 🤝 Контрибьюция

1. Сделай форк.
2. Создай ветку (`git checkout -b feature/Название`).
3. Закоммить (`git commit -m 'Описание'`).
4. Отправь pull request.

---

<p align="center">
  <b>Сделано с 💜 для SA-MP комьюнити</b><br>
  <i>Поставь ⭐, если мод помог!</i>
</p>