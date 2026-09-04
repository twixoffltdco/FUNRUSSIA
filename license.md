<div align="center">

# 🇷🇺 FUNRUSSIA

### Современная SA-MP сборка на базе мода Кранин

![Status](https://img.shields.io/badge/Status-Production-brightgreen?style=for-the-badge)
![Language](https://img.shields.io/badge/Language-Pawn-orange?style=for-the-badge)
![Database](https://img.shields.io/badge/Database-MySQL-4479A1?style=for-the-badge&logo=mysql&logoColor=white)
![Platform](https://img.shields.io/badge/Platform-Win%20%7C%20Linux-lightgrey?style=for-the-badge)

</div>

---

## 📌 О проекте

**FUNRUSSIA** — оптимизированная и полностью готовая к запуску сборка для SA-MP сервера. Включает современный стек плагинов, встроенную защиту, голосовой чат, систему фейк-онлайна и готовые SQL-миграции. Всё настроено — бери и запускай.

---

## ✨ Что внутри

| Фича | Описание |
|------|----------|
| 🛡️ **Античит** | Встроенная защита от основных эксплойтов и читов |
| 🎙️ **Голосовой чат** | `sampvoice` — общение прямо в игре без Discord |
| 📈 **Фейк-онлайн** | `FakeOnline` — сервер не уснёт на хостинге (см. раздел ниже) |
| ⚡ **JIT-компиляция** | Ускорение выполнения кода в несколько раз |
| 🗄️ **MySQL** | Полная работа с БД, готовые миграции в корне |
| 🧩 **Современный стек** | `Pawn.CMD`, `sscanf2`, `streamer`, `Pawn.RakNet`, `rustext` |

---

## ⚠️ ВАЖНО: Хостинг и FakeOnline

> Если вы арендуете сервер на **HostGta**, **MyHostGame**, **GameHost** или любом другом SA-MP хостинге — **обязательно включите FakeOnline**.
>
> Большинство хостингов автоматически останавливают или понижают в мониторинге серверы с нулевым онлайном. Это значит, что ваш сервер **умрёт**, так и не получив первых игроков.
>
> **Что сделать:**
> 1. Откройте `scriptfiles/fakeonline.ini`
> 2. Установите значение `15–30` ботов
> 3. Убедитесь, что `FakeOnline` прописан в `server.cfg` в строке `plugins`
>
> Это создаст видимость активности, сервер не уснёт, и реальные игроки начнут заходить.

---

## 📂 Структура

```
FUNRUSSIA/
├── gamemodes/              # Исходный код мода (.pwn / .amx)
├── filterscripts/          # FS: fakeonline, hgsystem
├── include/                # Инклуды: sscanf, streamer, pawnraknet, anticheat...
├── plugins/                # Плагины (.dll — Windows, .so — Linux)
├── scriptfiles/            # Конфиги: cases.json, fakeonline.ini, vehicles.json
├── pawno/                  # Компилятор и стандартные инклуды
├── KRANIN_DB_MIGRATION.sql # SQL-миграция базы данных (часть 1)
├── KRANIN_DB_MIGRATION2.sql# SQL-миграция базы данных (часть 2)
├── server.cfg              # Конфигурация сервера
├── ВАЖНО.txt               # Критические инструкции — читайте первым!
└── README.md               # Этот файл
```

---

## 🚀 Быстрый старт

### 1. Скачайте репозиторий

```bash
git clone https://gitverse.ru/twixoff/FUNRUSSIA.git
cd FUNRUSSIA
```

Или нажмите зелёную кнопку **«Скачать ZIP»** на странице репозитория и распакуйте.

### 2. Настройте базу данных

1. Создайте новую БД в MySQL (phpMyAdmin / DBeaver / панель хостинга).
2. Импортируйте `KRANIN_DB_MIGRATION.sql`, затем `KRANIN_DB_MIGRATION2.sql`.
3. Пропишите данные подключения (хост, логин, пароль, имя БД) в исходнике мода.

### 3. Скомпилируйте мод

- Откройте `gamemodes/new.pwn` в **Pawn Studio** или **PAWNO**.
- Нажмите `F5`.
- Убедитесь, что **0 Errors**. Warnings — по возможности исправьте.

### 4. Проверьте `server.cfg`

```ini
gamemode0 new 1
plugins crashdetect mysql pawncmd sscanf streamer sampvoice jit FakeOnline
```

> Для **Linux** уберите `.dll` и оставьте `.so` — плагины уже лежат в папке.

### 5. Запустите

- **Windows:** `samp-server.exe`
- **Linux:** `./samp03svr`

---

## 📤 Как залить на Gitverse / GitHub

Если вы форкнули мод и хотите запушить свои изменения:

```bash
git init
git branch -M main
git remote add origin https://gitverse.ru/ВАШ_ЛОГИН/ВАШ_РЕПО.git
git add .
git commit -m "FUNRUSSIA: initial upload"
git push -u origin main
```

---

## 🧰 Полный список плагинов

| Плагин | Зачем |
|--------|-------|
| `crashdetect` | Ловит краши и пишет подробный лог |
| `mysql` | Связь с базой данных |
| `sscanf2` | Парсинг аргументов в командах |
| `streamer` | Объекты, пикапы, маппинг без лимитов |
| `Pawn.RakNet` | Работа с пакетами и RPC |
| `sampvoice` | Голосовой чат в игре |
| `jit` | Ускорение мода в разы |
| `FakeOnline` | Боты для онлайна на хостинге |
| `profiler` | Профилирование и поиск узких мест |
| `Pawn.CMD` | Быстрые команды |

---

## 📜 Лицензия

Оригинальная основа — **мод Кранин**.  
Сборка распространяется «как есть». Используйте, дорабатывайте, запускайте.

> 📎 **Не забудьте прочитать `ВАЖНО.txt` перед первым запуском!**

---

<div align="center">

**Если сборка помогла — поставьте ⭐ репозиторию. Это лучшая благодарность.**

</div>