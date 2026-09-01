---
skip: {% if kind == "lib" %}true{% else %}false{% endif %}
---
import pytest

from {{ name | snake_case }} import main


def test_main(capsys: pytest.CaptureFixture[str]) -> None:
    main()

    assert capsys.readouterr().out == "Hello from {{ name }}!\n"
