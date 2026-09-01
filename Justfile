import '.just/format/Justfile'
import '.just/lint/Justfile'

mod build '.just/build'
mod test '.just/test'

[private]
default:
    just --list --list-submodules
