const $ = (s) => document.querySelector(s);

let booted = false;
let goalModal, openBtn, saveBtn, goalsList, tInput, bInput;
let goalsHidden, goalsEditor;

function resolveGoalsFields() {
    const hidden = document.querySelector('input[name="journal_entry[goals_for_tomorrow]"]');
    const editor = hidden ? document.querySelector(`trix-editor[input="${hidden.id}"]`) : null;
    return { hidden, editor };
}

function readGoalsHtml() {
    return goalsHidden?.value || "";
}

function writeGoalsHtml(nextHtml) {
    if (!goalsHidden) return;
    goalsHidden.value = nextHtml;
    goalsHidden.dispatchEvent(new Event("input", { bubbles: true }));
    goalsHidden.dispatchEvent(new Event("change", { bubbles: true }));
    if (goalsEditor?.editor) goalsEditor.editor.loadHTML(nextHtml);
}

function openModal() {
    goalModal.classList.add("is-open");
    goalModal.setAttribute("aria-hidden", "false");
    setTimeout(() => { if (tInput) tInput.focus(); }, 50);
}

function closeModal() {
    goalModal.classList.remove("is-open");
    goalModal.setAttribute("aria-hidden", "true");
}

function appendGoal(title, body) {
    const html = `
  <div class="goal">
    <strong>${title || "Untitled"}</strong>
    ${body ? `<div>${body.replace(/\n/g, "<br>")}</div>` : ""}
  </div>`.trim();
    const current = readGoalsHtml();
    const next = current + (current.trim() ? "\n" : "") + html;
    writeGoalsHtml(next);
}

function addGoalCard(title, bodyHtml) {
    if (!goalsList) return;
    const card = document.createElement("div");
    card.className = "goal-card";
    card.innerHTML = `
    <div class="goal-title">${title || "Untitled"}</div>
    ${bodyHtml ? `<div class="goal-text">${bodyHtml}</div>` : ""}`;
    goalsList.appendChild(card);
}

function extractBodyHTML(goalEl) {
    const children = Array.from(goalEl.children);
    const bodyParts = children.filter((el) => el.tagName.toLowerCase() !== "strong");
    return bodyParts.map((el) => el.innerHTML).join("").trim();
}

function renderExistingGoals() {
    ({ hidden: goalsHidden, editor: goalsEditor } = resolveGoalsFields());
    if (!goalsList) return;
    goalsList.replaceChildren();
    const html = goalsHidden?.value || "";
    if (!html.trim()) return;
    const tmp = document.createElement("div");
    tmp.innerHTML = html;
    let blocks = Array.from(tmp.querySelectorAll(".goal"));
    if (blocks.length === 0) blocks = Array.from(tmp.querySelectorAll("div, p")).filter((n) => n.querySelector("strong"));
    blocks.forEach((g) => {
        const title = g.querySelector("strong")?.textContent || "Untitled";
        const clone = g.cloneNode(true);
        const firstStrong = clone.querySelector("strong");
        if (firstStrong) firstStrong.remove();
        const bodyHtml = clone.innerHTML.trim();
        addGoalCard(title, bodyHtml);
    });
}

function bindUI() {
    goalModal?.addEventListener("click", (e) => {
        if (e.target.dataset.close === "goalModal") closeModal();
    });

    document.addEventListener("keydown", (e) => {
        if (e.key === "Escape" && goalModal.classList.contains("is-open")) closeModal();
    });

    openBtn?.addEventListener("click", openModal);

    saveBtn?.addEventListener("click", () => {
        const title = tInput.value.trim();
        const body = bInput.value.trim();
        if (!title && !body) return;
        addGoalCard(title, body.replace(/\n/g, "<br>"));
        appendGoal(title, body);
        tInput.value = "";
        bInput.value = "";
        closeModal();
    });
}

function init() {
    if (booted) return;
    booted = true;
    goalModal = $("#goalModal");
    openBtn = $("#openGoalModal");
    saveBtn = $("#saveGoal");
    goalsList = $("#goalsList");
    tInput = $("#goalTitle");
    bInput = $("#goalBody");
    ({ hidden: goalsHidden, editor: goalsEditor } = resolveGoalsFields());
    renderExistingGoals();
    bindUI();
}

document.addEventListener("DOMContentLoaded", init);
document.addEventListener("turbo:load", () => { booted = false; init(); });
document.addEventListener("trix-initialize", () => {
    ({ hidden: goalsHidden, editor: goalsEditor } = resolveGoalsFields());
    renderExistingGoals();
});

document.addEventListener("submit", (e) => {
    const btn = e.target.querySelector(".btn-primary");
    if (!btn) return;
    btn.classList.add("is-loading");
    btn.setAttribute("aria-busy", "true");
    btn.disabled = true;
});
