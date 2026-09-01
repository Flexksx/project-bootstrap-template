---
skip: {% if kind == "app" %}true{% else %}false{% endif %}
---
from {{ name | snake_case }} import hello


def test_hello() -> None:
    assert hello() == "Hello from {{ name }}!"
