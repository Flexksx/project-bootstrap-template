import '.just/format/Justfile'
import '.just/lint/Justfile'

mod build '.just/build'
mod test '.just/test'
mod start '.just/start'
mod new '.just/new'

[private]
default:
    just --list --list-submodules

# Rebuild the unit indexes
sync:
    ./.just/units.sh
