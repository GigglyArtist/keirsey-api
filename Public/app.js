//
//  app.js
//  KeirseyApi
//

// Состояние = единственный источник правды
const state = {
  current: 0,                                   // индекс текущего вопроса
  pending: null,
  answers: new Array(QUESTIONS.length).fill(null), // 'a' | 'b' | null
};

const els = {
  progress: document.getElementById("progress"),
  counter: document.getElementById("counter"),
  card: document.getElementById("card"),
};

// перерисовываем карточку целиком при каждом изменении
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
    ${state.current > 0 ? '<button id="back" class="text-sm text-slate-400 hover:text-indigo-500 transition">← Назад</button>' : ""}
    <h2 class="text-xl font-medium text-slate-800">${q.t}</h2>
    <button data-answer="a" class="w-full text-left rounded-xl border-2 border-slate-200 hover:border-indigo-400 hover:bg-indigo-50 p-4 transition">
      <span class="font-semibold text-indigo-500">а)</span> ${q.a}
    </button>
    <button data-answer="b" class="w-full text-left rounded-xl border-2 border-slate-200 hover:border-indigo-400 hover:bg-indigo-50 p-4 transition">
      <span class="font-semibold text-indigo-500">б)</span> ${q.b}
    </button>
    <button id="confirm" disabled class="w-full rounded-xl bg-indigo-500 hover:bg-indigo-600 disabled:opacity-40 disabled:cursor-not-allowed text-white font-semibold p-4 transition">
      Подтвердить ответ
    </button>
  `;

  els.card.querySelectorAll("button[data-answer]").forEach((btn) => {
    btn.addEventListener("click", () => select(btn.dataset.answer));
  });
  document.getElementById("confirm").addEventListener("click", confirmAnswer);
  const backBtn = document.getElementById("back");
  if (backBtn) backBtn.addEventListener("click", () => {
    state.pending = null;
    state.current -= 1;
    render();
  });

  els.card.classList.remove("card-in");
  void els.card.offsetWidth;
  els.card.classList.add("card-in");
}

function select(variant) {
  state.pending = variant;
  // Не перерисовываем карточку, только классы и кнопку
  els.card.querySelectorAll("button[data-answer]").forEach((btn) => {
    const isSel = btn.dataset.answer === variant;
    btn.classList.toggle("border-indigo-500", isSel);
    btn.classList.toggle("bg-indigo-50", isSel);
    btn.classList.toggle("ring-2", isSel);
    btn.classList.toggle("ring-indigo-200", isSel);
    btn.classList.toggle("border-slate-200", !isSel);
  });
  document.getElementById("confirm").disabled = false;
}

function confirmAnswer() {
  if (!state.pending) return;
  state.answers[state.current] = state.pending;
  state.pending = null;
  state.current += 1;
  saveDraft();
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
    
  els.card.classList.remove("card-in");
  void els.card.offsetWidth;
  els.card.classList.add("card-in");
}

const STORAGE_KEY = "keirsey-draft";

function saveDraft() {
  localStorage.setItem(STORAGE_KEY, JSON.stringify(state));
}

function loadDraft() {
  try {
    const raw = localStorage.getItem(STORAGE_KEY);
    if (!raw) return;
    const draft = JSON.parse(raw);
    // Валидируем данные
    if (Array.isArray(draft.answers) && draft.answers.length === QUESTIONS.length) {
      state.answers = draft.answers;
      state.current = Math.min(draft.current ?? 0, QUESTIONS.length);
    }
  } catch {
    // черновик побит - молча начинаем заново
  }
}

loadDraft();

document.addEventListener("keydown", (e) => {
  if (e.code === "Escape") { closeModal(); return; }
  if (state.current >= QUESTIONS.length) return;
  if (e.code === "KeyA") select("a");
  if (e.code === "KeyB") select("b");
  if (e.code === "Enter") confirmAnswer();
});

render();

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
    // Сюда падаем, если ответа НЕТ вовсе: сервер выключен, нет сети, DNS…
    renderError("Не удалось связаться с сервером. Убедитесь, что он запущен, и попробуйте ещё раз.");
  }
}

// Ошибка Vapor имеет вид {"error": true, "reason": "..."} - вытаскиваем reason
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
    <button id="full-desc" class="w-full rounded-xl border-2 border-indigo-500 text-indigo-500 hover:bg-indigo-50 font-semibold p-4 transition">
      Показать полную расшифровку
    </button>
    <button id="restart" class="w-full rounded-xl bg-indigo-500 hover:bg-indigo-600 text-white font-semibold p-4 transition">
      Пройти заново
    </button>
  `;
  document.getElementById("restart").addEventListener("click", restart);
  document.getElementById("full-desc").addEventListener("click", () => openModal(result.code));
  localStorage.removeItem(STORAGE_KEY);
    
  els.card.classList.remove("card-in");
  void els.card.offsetWidth;
  els.card.classList.add("card-in");
}

function openModal(code) {
  const full = FULL_DESCRIPTIONS[code] ?? "Текст расшифровки временно отсутствует.";
  document.getElementById("modal-title").textContent = `${code} — полная расшифровка`;
  document.getElementById("modal-text").textContent = full;
  const modal = document.getElementById("modal");
  modal.classList.remove("hidden");
  modal.classList.add("flex");
}

function closeModal() {
  const modal = document.getElementById("modal");
  modal.classList.add("hidden");
  modal.classList.remove("flex");
}

document.getElementById("modal-close").addEventListener("click", closeModal);

// Клик по затемнённому фону (но не по самому окну) тоже закрывает
document.getElementById("modal").addEventListener("click", (e) => {
  if (e.target === e.currentTarget) closeModal();
});

function renderError(message) {
  els.card.innerHTML = `
    <h2 class="text-xl font-semibold text-rose-600">Что-то пошло не так</h2>
    <p class="text-slate-600">${message}</p>
    <button id="retry" class="w-full rounded-xl bg-indigo-500 hover:bg-indigo-600 text-white font-semibold p-4 transition">
      Попробовать снова
    </button>
  `;
  document.getElementById("retry").addEventListener("click", renderFinish);
    
  els.card.classList.remove("card-in");
  void els.card.offsetWidth;
  els.card.classList.add("card-in");
}

function restart() {
  state.current = 0;
  state.answers = new Array(QUESTIONS.length).fill(null);
  render();
  localStorage.removeItem(STORAGE_KEY);
}
