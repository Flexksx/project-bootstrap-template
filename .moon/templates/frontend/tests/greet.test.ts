import { expect, test } from "vitest";
import { greet } from "{% if framework == "sveltekit" %}../src/lib/greet{% else %}../app/greet{% endif %}";

test("greet names the app", () => {
  expect(greet("{{ name }}")).toBe("Hello, {{ name }}!");
});
