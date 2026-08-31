{% if kind == "app" %}def run() -> int:
    print("{{ name }}")
    return 0
{%- else %}def hello() -> str:
    return "{{ name }}"
{%- endif %}
