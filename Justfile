import '.just/format/Justfile'
import '.just/lint/Justfile'
import '.just/build/Justfile'
import '.just/test/Justfile'

import? '.just/units.just'

[private]
default:
    just --list --list-submodules

# Rebuild the unit index
sync:
    ./.just/units.sh
