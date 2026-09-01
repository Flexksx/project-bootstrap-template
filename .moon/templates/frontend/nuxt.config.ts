---
skip: {% if framework == "sveltekit" %}true{% else %}false{% endif %}
---
export default defineNuxtConfig({
  compatibilityDate: "2026-01-01",
  devtools: { enabled: true },
});
