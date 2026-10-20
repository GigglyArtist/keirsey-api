# Keirsey API + Web
Изолированный опросник Кейрси (70 вопросов, 4 шкалы) с веб-интерфейсом.
Stateless-сервис без базы данных: принимает ответы, считает код психотипа, отдаёт описание.

## Стек
- **Backend:** Swift, Vapor 4 (SPM)
- **Frontend:** HTML + Tailwind CSS (CDN) + Vanilla JS, раздаётся из `Public/`
- **Deploy:** Render.com (Docker)

## Локальный запуск
```bash
swift run                 # http://127.0.0.1:8080
swift test                # unit-тесты алгоритма + роутов

API:
POST /api/v1/keirsey/result

Запрос:
{ "answers": { "1": "a", "2": "b", "…": "…", "70": "a" } }

Ответ 200:
{ "code": "ESTJ", "title": "Администратор", "description": "…" }

Структура:
Sources/KeirseyApi/Keirsey/ - домен: алгоритм подсчёта, описания психотипов (без зависимостей от Vapor)
Sources/KeirseyApi/Controllers/ - HTTP-слой: DTO и валидация входа
Public/ - фронтенд (index.html, questions.js, app.js)
Tests/ — XCTest (алгоритм) + Swift Testing (роуты)

Правила подсчёта:
Ответ «а» = +1 левой букве шкалы (E/S/T/J), «б» = +1 правой (I/N/F/P).
При равенстве голосов выбирается правая буква (I, N, F, P).
