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
    <p class="text-slate-500">Кнопка ниже пока печатает payload в консоль</p>
    <button id="submit" class="w-full rounded-xl bg-indigo-500 hover:bg-indigo-600 text-white font-semibold p-4 transition">
      Показать результат
    </button>
  `;
  document.getElementById("submit").addEventListener("click", () => {
    const payload = {
      answers: Object.fromEntries(
        state.answers.map((v, i) => [String(i + 1), v])
      ),
    };
    console.log("Payload для API:", payload);
  });
}

render();
