# Place this in your Fish functions folder to make it available immediately
# e.g. ~/.config/fish/functions/envsource.fish
# If any change is made, source this file
#sortin
# Usage: envsource <path/to/env>

function envsource
  for line in (cat $argv | grep -v '^#' | grep -v '^\s*$' | grep -E '^\s*(.*)=.*$')
    set item (string split -m 1 = $line)
    set chars_to_remove "'\""
    set first_char (echo $item[2] | grep -o "[$chars_to_remove]" | head -1)
    set item[2] (echo $item[2] | string trim --chars=$first_char)
    set -Ux $item[1] $item[2]
    echo "Exported key $item[1] with value $item[2]"
  end
end
