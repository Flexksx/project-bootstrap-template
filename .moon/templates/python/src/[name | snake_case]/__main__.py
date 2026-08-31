---
skip: {% if kind != "app" %}true{% endif %}
---
import sys

from {{ name | snake_case }} import run

sys.exit(run())
