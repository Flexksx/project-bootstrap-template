---
skip: {% if framework == "nuxt" %}true{% else %}false{% endif %}
---
export function greet(name: string): string {
  return `Hello, ${name}!`;
}
