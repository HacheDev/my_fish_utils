# Place this in your Fish functions folder to make it available immediately
# e.g. ~/.config/fish/functions/envunsource.fish
# If any change is made, source this file
#
# Usage: envsource <path/to/env>

function envunsource
  for line in (cat $argv | grep -v '^#' | grep -v '^\s*$')
    set item (string split -m 1 '=' $line)
    set chars_to_remove "'\""
    set result (string trim --chars=$chars_to_remove $item[1])
    echo "Deleting key $result"
    set -e (echo $result)
    echo "Deleted key $result"
  end
end
