//
//  app.js
//  KeirseyApi
//

// Состояние = единственный источник правды
const state = {
  current: 0,                                   // индекс текущего вопроса
  answers: new Array(QUESTIONS.length).fill(null), // 'a' | 'b' | null
};

const els = {
  progress: document.getElementById("progress"),
  counter: document.getElementById("counter"),
  card: document.getElementById("card"),
};

// перерисовываю карточку целиком при каждом изменении
function render() {
  const answered = state.answers.filter(Boolean).length;
  els.progress.style.width = `${(answered / QUESTIONS.length) * 100}%`;

  if (state.current >= QUESTIONS.length) {
    renderFinish();
    return;
  }

  const q = QUESTIONS[state.current];
  els.counter.textContent = `Вопрос ${state.current + 1} из ${QUESTIONS.length}`;
  els.card.innerHTML = `
    <h2 class="text-xl font-medium text-slate-800">${q.t}</h2>
    <button data-answer="a" class="w-full text-left rounded-xl border-2 border-slate-200 hover:border-indigo-400 hover:bg-indigo-50 p-4 transition">
      <span class="font-semibold text-indigo-500">а)</span> ${q.a}
    </button>
    <button data-answer="b" class="w-full text-left rounded-xl border-2 border-slate-200 hover:border-indigo-400 hover:bg-indigo-50 p-4 transition">
      <span class="font-semibold text-indigo-500">б)</span> ${q.b}
    </button>
  `;

  // innerHTML уничтожил старые кнопки вместе с их слушателями, так что вешаю заново
  els.card.querySelectorAll("button[data-answer]").forEach((btn) => {
    btn.addEventListener("click", () => choose(btn.dataset.answer));
  });
}

function choose(variant) {
  state.answers[state.current] = variant;
  state.current += 1;
  render();
}

function renderFinish() {
  els.counter.textContent = "Готово!";
  els.progress.style.width = "100%";
  els.card.innerHTML = `
    <h2 class="text-2xl font-semibold text-slate-800">Все 70 вопросов отвечены 🎉</h2>
    <p class="text-slate-500">Нажми кнопку и сервер посчитает твой код психотипа</p>
    <button id="submit" class="w-full rounded-xl bg-indigo-500 hover:bg-indigo-600 text-white font-semibold p-4 transition">
      Показать результат
    </button>
  `;
    
  document.getElementById("submit").addEventListener("click", submitAnswers);
}

// Связь с сервером
async function submitAnswers() {
  const payload = {
    answers: Object.fromEntries(state.answers.map((v, i) => [String(i + 1), v])),
  };

  const btn = document.getElementById("submit");
  btn.disabled = true;              // защита от двойного тапа
  btn.textContent = "Отправляем…";

  try {
    const response = await fetch("/api/v1/keirsey/result", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(payload),
    });

    if (!response.ok) {             // 400, 422, 500…
      renderError(await extractReason(response));
      return;
    }

    renderResult(await response.json());
  } catch (error) {
    // Сюда падаю, если ответа НЕТ вовсе: сервер выключен, нет сети, DNS…
    renderError("Не удалось связаться с сервером. Убедитесь, что он запущен, и попробуйте ещё раз.");
  }
}

// Ошибка Vapor имеет вид {"error": true, "reason": "..."} - вытаскиваю reason
async function extractReason(response) {
  try {
    const body = await response.json();
    return body.reason ?? `Ошибка сервера: ${response.status}`;
  } catch {
    return `Ошибка сервера: ${response.status}`;
  }
}

function renderResult(result) {
  els.counter.textContent = "Результат";
  els.progress.style.width = "100%";
  els.card.innerHTML = `
    <div class="text-center space-y-2">
      <p class="text-5xl font-black tracking-widest text-indigo-500">${result.code}</p>
      <h2 class="text-2xl font-semibold text-slate-800">${result.title}</h2>
    </div>
    <p class="text-slate-600 leading-relaxed">${result.description}</p>
    <button id="restart" class="w-full rounded-xl bg-indigo-500 hover:bg-indigo-600 text-white font-semibold p-4 transition">
      Пройти заново
    </button>
  `;
  document.getElementById("restart").addEventListener("click", restart);
}

function renderError(message) {
  els.card.innerHTML = `
    <h2 class="text-xl font-semibold text-rose-600">Что-то пошло не так</h2>
    <p class="text-slate-600">${message}</p>
    <button id="retry" class="w-full rounded-xl bg-indigo-500 hover:bg-indigo-600 text-white font-semibold p-4 transition">
      Попробовать снова
    </button>
  `;
  document.getElementById("retry").addEventListener("click", renderFinish);
}

function restart() {
  state.current = 0;
  state.answers = new Array(QUESTIONS.length).fill(null);
  render();
}

render();
