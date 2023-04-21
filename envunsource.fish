# Place this in your Fish functions folder to make it available immediately
# e.g. ~/.config/fish/functions/envunsource.fish
# If any change is made, source this file
#
# Usage: envsource <path/to/env>

function envunsource
  for line in (cat $argv | grep -v '^#' | grep -v '^\s*$' | grep -E '^\s*(.*)=.*$')
    set item (string split -m 1 '=' $line)
    echo "Deleting key $item[1]"cp
    set -e (echo $item[1])
    echo "Deleted key $item[1]"
  end
end
