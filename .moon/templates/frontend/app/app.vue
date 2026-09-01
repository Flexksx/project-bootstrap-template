---
skip: {% if framework == "sveltekit" %}true{% else %}false{% endif %}
---
<script setup lang="ts">
import { greet } from "./greet";

const greeting = greet("{{ name }}");
</script>

<template>
  <h1>{% raw %}{{ greeting }}{% endraw %}</h1>
</template>
