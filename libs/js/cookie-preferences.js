document.addEventListener("DOMContentLoaded", () => {
    const preferences_link = document.querySelector("#open_preferences_center");

    preferences_link?.addEventListener("click", (event) => {
        const open_preferences = window.cookieconsent?.openPreferencesCenter;

        if (typeof open_preferences !== "function") return;

        event.preventDefault();
        event.stopImmediatePropagation();
        open_preferences();
    }, true);
});
