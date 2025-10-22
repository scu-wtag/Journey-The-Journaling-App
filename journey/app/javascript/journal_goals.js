const $ = s => document.querySelector(s);

const goalModal = $('#goalModal');
const openBtn = $('#openGoalModal');
const saveBtn = $('#saveGoal');
const goalsList = $('#goalsList');
const tInput = $('#goalTitle');
const bInput = $('#goalBody');

function resolveGoalsFields() {
  const hidden = document.querySelector('input[name="journal_entry[goals_for_tomorrow]"]');
  const editor = hidden ? document.querySelector(`trix-editor[input="${hidden.id}"]`) : null;
  return { hidden, editor };
}

let { hidden: goalsHidden, editor: goalsEditor } = resolveGoalsFields();

document.addEventListener("trix-initialize", () => {
  ({ hidden: goalsHidden, editor: goalsEditor } = resolveGoalsFields());
});

function openModal() {
  goalModal.classList.add('is-open');
  goalModal.setAttribute('aria-hidden', 'false');
  setTimeout(() => tInput?.focus(), 50);
}

function closeModal() {
  goalModal.classList.remove('is-open');
  goalModal.setAttribute('aria-hidden', 'true');
}

openBtn?.addEventListener('click', openModal);
goalModal?.addEventListener('click', e => {
  if (e.target.dataset.close === 'goalModal') closeModal();
});
document.addEventListener('keydown', e => {
  if (e.key === 'Escape' && goalModal.classList.contains('is-open')) closeModal();
});

function appendGoalToTrixOrInput(title, body) {
  const html = `
<div class="goal">
  <strong>${title || 'Untitled'}</strong>
  ${body ? `<div>${body.replace(/\n/g, '<br>')}</div>` : ''}
</div>`.trim();

  if (goalsEditor?.editor) {
    goalsEditor.editor.insertHTML(html);
  } else if (goalsHidden) {
    const current = goalsHidden.value || "";
    goalsHidden.value = current + (current.trim() ? "\n" : "") + html;
    goalsHidden.dispatchEvent(new Event('input', { bubbles: true }));
    goalsHidden.dispatchEvent(new Event('change', { bubbles: true }));
  }
}

function addGoalCardToList(title, body) {
  if (!goalsList) return;
  const card = document.createElement('div');
  card.className = 'goal-card';
  card.innerHTML = `
<div class="goal-title">${title || 'Untitled'}</div>
${body ? `<div class="goal-text">${body.replace(/\n/g, '<br>')}</div>` : ''}`;
  goalsList.appendChild(card);
}

saveBtn?.addEventListener('click', () => {
  const title = tInput.value.trim();
  const body = bInput.value.trim();
  if (!title && !body) return;

  addGoalCardToList(title, body);
  appendGoalToTrixOrInput(title, body);

  tInput.value = '';
  bInput.value = '';
  tInput.blur();
  bInput.blur();

  closeModal();
});

document.addEventListener('DOMContentLoaded', () => {
  ({ hidden: goalsHidden, editor: goalsEditor } = resolveGoalsFields());

  let html = '';
  if (goalsEditor?.editor) {
    html = goalsEditor.editor.getDocument().toString() || '';
  } else if (goalsHidden) {
    html = goalsHidden.value || '';
  }
  if (!html.trim()) return;

  const tmp = document.createElement('div');
  tmp.innerHTML = html;

  const blocks = Array.from(tmp.querySelectorAll('div')).filter(d => d.querySelector(':scope > strong'));

  blocks.forEach(g => {
    const title = g.querySelector(':scope > strong')?.textContent || 'Untitled';
    const bodyDiv = g.querySelector(':scope > div');
    const bodyHtml = bodyDiv ? bodyDiv.innerHTML : '';
    addGoalCardToList(title, bodyHtml.replace(/\n/g, '<br>'));
  });
});
