# Place this in your Fish functions folder to make it available immediately
# e.g. ~/.config/fish/functions/envsource.fish
# If any change is made, source this file
#
# Usage: envsource <path/to/env>

function envsource
  for line in (cat $argv | grep -v '^#' | grep -v '^\s*$')
    set item (string split -m 1 = $line)
    set chars_to_remove "'\""
    set result[1] (string trim --chars=$chars_to_remove $item[1])
    set first_char (echo $item[2] | grep -o "[$chars_to_remove]" | head -1)
    set result[2] (echo $item[2] | string trim --chars=$first_char)
    set -Ux $result[1] $result[2]
    echo "Exported key $result[1] with value $result[2]"
  end
end
