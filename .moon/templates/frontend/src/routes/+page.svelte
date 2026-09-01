---
skip: {% if framework == "nuxt" %}true{% else %}false{% endif %}
---
<script lang="ts">
import { greet } from "$lib/greet";
</script>

<h1>{greet("{{ name }}")}</h1>
