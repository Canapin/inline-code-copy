import { apiInitializer } from "discourse/lib/api";

export default apiInitializer((api) => {
  api.decorateCookedElement((element) => {
    element.querySelectorAll("code").forEach((el) => {
      // Fenced code blocks already have a copy button from Discourse core.
      if (el.closest("pre")) {
        return;
      }

      // A cooked element can be decorated more than once.
      if (el.dataset.inlineCopyReady) {
        return;
      }
      el.dataset.inlineCopyReady = "true";

      el.classList.add("inline-copy");
      el.setAttribute("role", "button");
      el.setAttribute("tabindex", "0");
      el.setAttribute("aria-label", "Copy inline code");
      el.title = "Click to copy";

      const text = el.textContent;
      let moved = false;

      const doCopy = (event) => {
        event.preventDefault();
        copyToClipboard(text).then(() => {
          el.classList.add("copied");
          window.setTimeout(() => el.classList.remove("copied"), 1200);
        });
      };

      // Click supports mouse input and synthesized clicks on modern touch browsers.
      el.addEventListener("click", doCopy);

      // Suppress the synthesized click after a tap while keeping scrolling passive.
      el.addEventListener("touchstart", () => (moved = false), {
        passive: true,
      });
      el.addEventListener("touchmove", () => (moved = true), {
        passive: true,
      });
      el.addEventListener("touchend", (event) => {
        if (!moved) {
          doCopy(event);
        }
      });

      el.addEventListener("keydown", (event) => {
        if (event.key === "Enter" || event.key === " ") {
          doCopy(event);
        }
      });
    });
  });
});

function copyToClipboard(text) {
  if (navigator.clipboard && window.isSecureContext) {
    return navigator.clipboard.writeText(text).catch(() => legacyCopy(text));
  }

  return Promise.resolve(legacyCopy(text));
}

function legacyCopy(text) {
  const textarea = document.createElement("textarea");
  textarea.value = text;
  textarea.setAttribute("readonly", "");
  textarea.style.position = "fixed";
  textarea.style.left = "-9999px";
  document.body.appendChild(textarea);
  textarea.select();
  textarea.setSelectionRange(0, textarea.value.length);
  document.execCommand("copy");
  document.body.removeChild(textarea);
}
