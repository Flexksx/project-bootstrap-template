---
skip: {% if framework == "nuxt" %}true{% else %}false{% endif %}
---
import { sveltekit } from "@sveltejs/kit/vite";
import { defineConfig } from "vite";

export default defineConfig({
  plugins: [sveltekit()],
});
