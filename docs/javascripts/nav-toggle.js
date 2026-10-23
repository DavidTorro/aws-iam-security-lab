// Botón para expandir o colapsar todas las secciones de la navegación
document.addEventListener("DOMContentLoaded", () => {
  const navigation = document.querySelector(".md-sidebar--primary .md-nav--primary");
  const title = navigation?.querySelector(":scope > .md-nav__title");

  if (!navigation || !title) return;

  const toggles = () => [
    ...navigation.querySelectorAll('input.md-nav__toggle[id^="__nav_"]'),
  ];

  if (!toggles().length) return;

  const button = document.createElement("button");
  button.className = "nav-toggle";
  button.type = "button";
  title.append(button);

  const icons = {
    expand: '<svg viewBox="0 0 24 24" aria-hidden="true"><path d="m12 5.83 3.17 3.17 1.41-1.41L12 3 7.41 7.59 8.83 9zm0 12.34L8.83 15l-1.42 1.41L12 21l4.59-4.59L15.17 15z"/></svg>',
    collapse: '<svg viewBox="0 0 24 24" aria-hidden="true"><path d="m12 10.17 3.17-3.17 1.41 1.41L12 13 7.41 8.41 8.83 7zm0 3.66L8.83 17l-1.42-1.41L12 11l4.59 4.59L15.17 17z"/></svg>',
  };

  const updateButton = () => {
    const expanded = toggles().every((toggle) => toggle.checked);
    const action = expanded ? "Colapsar todo" : "Expandir todo";
    button.innerHTML = expanded ? icons.collapse : icons.expand;
    button.title = action;
    button.setAttribute("aria-label", action);
    button.setAttribute("aria-expanded", String(expanded));
  };

  button.addEventListener("click", (event) => {
    event.preventDefault();
    event.stopPropagation();
    const shouldExpand = toggles().some((toggle) => !toggle.checked);
    toggles().forEach((toggle) => {
      toggle.checked = shouldExpand;
      toggle.dispatchEvent(new Event("change", { bubbles: true }));
    });
    updateButton();
  });

  toggles().forEach((toggle) => toggle.addEventListener("change", updateButton));
  updateButton();
});
