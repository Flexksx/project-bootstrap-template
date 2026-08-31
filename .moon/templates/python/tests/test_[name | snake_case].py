{% if kind == "app" %}from {{ name | snake_case }} import run


def test_run() -> None:
    assert run() == 0
{%- else %}from {{ name | snake_case }} import hello


def test_hello() -> None:
    assert hello() == "{{ name }}"
{%- endif %}
