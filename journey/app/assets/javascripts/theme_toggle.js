(function () {
    function setCookieTheme(theme) {
        document.cookie = `theme=${theme}; path=/; max-age=${60 * 60 * 24 * 365}; SameSite=Lax${location.protocol === 'https:' ? '; Secure' : ''}`;
    }

    async function persistToUser(theme) {
        try {
            if (!window.JOURNEY_PROFILE_PATH) return;
            const token = document.querySelector('meta[name="csrf-token"]')?.content;
            await fetch(window.JOURNEY_PROFILE_PATH, {
                method: "PATCH",
                headers: {
                    "X-CSRF-Token": token || "",
                    "Content-Type": "application/json",
                    "Accept": "application/json"
                },
                body: JSON.stringify({ user: { theme } })
            });
        } catch (_) { }
    }

    async function applyTheme(theme) {
        if (!["light", "dark"].includes(theme)) return;
        document.documentElement.setAttribute("data-theme", theme);
        setCookieTheme(theme);
        await persistToUser(theme);
    }

    function init() {
        const toggle = document.getElementById("themeToggle");
        if (toggle) {
            toggle.checked = (document.documentElement.getAttribute("data-theme") === "dark");
            toggle.addEventListener("change", () => applyTheme(toggle.checked ? "dark" : "light"));
        }

        document.addEventListener("click", (e) => {
            const el = e.target.closest("[data-set-theme]");
            if (!el) return;
            e.preventDefault();
            const theme = el.getAttribute("data-set-theme");
            applyTheme(theme);
        });
    }

    document.addEventListener("turbo:load", init);
    document.addEventListener("DOMContentLoaded", init);
})();
