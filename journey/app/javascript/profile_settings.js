const editBtn = document.getElementById('editBtn');
const saveBar = document.getElementById('saveBar');
const saveBtn = document.getElementById('saveBtn');
const cancelBtn = document.getElementById('cancelBtn');

const detailsForm = document.getElementById('detailsForm');
const detailsContainer = document.getElementById('details');

let inputs = [];
let originals = new Map();

function toInput(el) {
  const type = el.dataset.type || 'text';
  const key = el.dataset.key;
  const scope = el.dataset.scope || (key === 'email' ? 'user' : 'profile');
  const val = el.textContent.trim();

  const input = document.createElement('input');
  input.className = 'input';
  input.value = val;
  input.setAttribute('data-key', key);
  input.setAttribute('data-scope', scope);
  input.type = (type === 'date' || type === 'email') ? type : 'text';

  input.name = scope === 'user' ? `user[${key}]` : `profile[${key}]`;

  if (key === 'phone' && scope === 'profile') {
    input.name = '';

    const hiddenCode = document.createElement('input');
    hiddenCode.type = 'hidden';
    hiddenCode.name = 'profile[phone_country_code]';

    const hiddenLocal = document.createElement('input');
    hiddenLocal.type = 'hidden';
    hiddenLocal.name = 'profile[phone_local]';

    function fillHiddenFrom(v) {
      const digitsOnly = (v || '').replace(/[^\d+]/g, '');
      const m = digitsOnly.match(/^\+?(\d{1, 4})?(\d{4,})$/);
      if (m) {
        hiddenCode.value = (m[1] || '').replace(/\D/g, '');
        hiddenLocal.value = (m[2] || '').replace(/\D/g, '');
      } else {
        hiddenCode.value = '';
        hiddenLocal.value = digitsOnly.replace(/\D/g, '');
      }
    }
    fillHiddenFrom(val);
    input.addEventListener('input', () => fillHiddenFrom(input.value));

    detailsForm?.appendChild(hiddenCode);
    detailsForm?.appendChild(hiddenLocal);
  }

  el.replaceWith(input);
  return input;
}

function toDisplay(input) {
  const div = document.createElement('div');
  div.className = 'profile__kv-value';
  div.dataset.key = input.dataset.key;
  div.dataset.scope = input.dataset.scope;
  div.dataset.type = input.type === 'text' ? 'text' : input.type;
  div.textContent = input.value.trim();
  input.replaceWith(div);
  return div;
}

function enterEditMode() {
  if (inputs.length) return;
  originals.clear();
  inputs = [];
  const editable = detailsContainer.querySelectorAll('.profile__kv-value');
  editable.forEach(el => {
    originals.set(`${el.dataset.scope}.${el.dataset.key}`, el.textContent.trim());
    const input = toInput(el);
    inputs.push(input);
  });
  editBtn.disabled = true;
  saveBar.style.display = 'flex';
  inputs[0]?.focus();
}

function exitEditMode(save) {
  if (!inputs.length) return;
  if (save) {
    inputs.forEach(inp => toDisplay(inp));
  } else {
    inputs.forEach(inp => {
      const key = inp.dataset.key;
      const scope = inp.dataset.scope;
      const disp = document.createElement('div');
      disp.className = 'profile__kv-value';
      disp.dataset.key = key;
      disp.dataset.scope = scope;
      disp.dataset.type = inp.type === 'text' ? 'text' : inp.type;
      disp.textContent = originals.get(`${scope}.${key}`) ?? '';
      inp.replaceWith(disp);
    });
  }
  inputs = [];
  editBtn.disabled = false;
  saveBar.style.display = 'none';
}

editBtn?.addEventListener('click', enterEditMode);
saveBtn?.addEventListener('click', () => detailsForm?.requestSubmit());
cancelBtn?.addEventListener('click', () => exitEditMode(false));

const langSelect = document.getElementById('langSelect');

function pathWithLocale(locale) {
  const { pathname, search, hash } = window.location;
  const stripped = pathname.replace(/^\/(en|de)(?=\/|$)/, '');
  return `/${locale}${stripped}${search}${hash}`;
}
langSelect?.addEventListener('change', async (e) => {
  const locale = e.target.value;

  try {
    await fetch("<%= profile_path %>", {
      method: "PATCH",
      headers: {
        "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content,
        "Content-Type": "application/json",
        "Accept": "application/json"
      },
      body: JSON.stringify({ user: { locale } })
    });
  } catch (_) { }

  window.location.assign(pathWithLocale(locale));
});

const themeToggle = document.getElementById('themeToggle');

(function syncInitialTheme() {
  const current = document.documentElement.getAttribute('data-theme') || 'light';
  if (themeToggle) themeToggle.checked = (current === 'dark');
})();

function setCookieTheme(val) {
  document.cookie =
    `theme=${val}; path=/; max-age=${60 * 60 * 24 * 365}; SameSite=Lax${location.protocol === 'https:' ? '; Secure' : ''}`;
}

async function persistUserTheme(val) {
  try {
    await fetch("<%= profile_path %>", {
      method: "PATCH",
      headers: {
        "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content,
        "Content-Type": "application/json",
        "Accept": "application/json"
      },
      body: JSON.stringify({ user: { theme: val } })
    });
  } catch (_) { }
}

themeToggle?.addEventListener('change', async () => {
  const next = themeToggle.checked ? 'dark' : 'light';

  document.documentElement.setAttribute('data-theme', next);

  setCookieTheme(next);

  await persistUserTheme(next);
});

document.addEventListener('turbo:render', () => {
  const meta = document.querySelector('meta[name="theme"]');
  if (!meta) return;
  document.documentElement.setAttribute('data-theme', meta.content);
  if (themeToggle) themeToggle.checked = (meta.content === 'dark');
});
const editAvatar = document.getElementById('editAvatar');
const avatarInput = document.getElementById('avatarInput');
const avatarForm = document.getElementById('avatarForm');
const avatarImg = document.getElementById('avatarImg');

editAvatar?.addEventListener('click', (e) => {
  e.preventDefault();
  avatarInput?.click();
});

avatarInput?.addEventListener('change', (e) => {
  const file = e.target.files && e.target.files[0];
  if (!file) return;
  const reader = new FileReader();
  reader.onload = (ev) => { if (avatarImg) avatarImg.src = ev.target.result; };
  reader.readAsDataURL(file);
  editAvatar?.setAttribute('disabled', 'disabled');
  avatarForm?.requestSubmit();
});

document.addEventListener('DOMContentLoaded', () => {
  const a = document.getElementById('backLink');
  if (!a) return;

  const theme = document.documentElement.getAttribute('data-theme') || 'light';
  const locale = '<%= I18n.locale %>';
  const ref = document.referrer;

  function withLocale(pathname, loc) {
    const stripped = pathname.replace(/^\/(en|de)(?=\/|$)/, '');
    return `/${loc}${stripped || '/'}`.replace(/\/{2,}/g, '/');
  }

  a.addEventListener('click', (e) => {
    e.preventDefault();

    let url;
    if (ref && ref.startsWith(window.location.origin)) {
      url = new URL(ref);
    } else {
      url = new URL('<%= journal_entries_path(locale: I18n.locale) %>', window.location.origin);
    }

    url.pathname = withLocale(url.pathname, locale);

    url.searchParams.set('theme', theme);

    window.location.assign(url.toString());
  });
});
