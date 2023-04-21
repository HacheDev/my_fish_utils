# Place this in your Fish functions folder to make it available immediately
# e.g. ~/.config/fish/functions/envsource.fish
# If any change is made, source this file
#sortin
# Usage: envsource <path/to/env>

function envsource
    set num_of_args (count $argv)
    if test $num_of_args -gt 1 -a (string match -q -- -"$argv[1]")
        set options $argv[1]
    else
        set options "-U"
    end
    for line in (cat $argv[2] | grep -v '^#' | grep -v '^\s*$' | grep -E '^\s*(.*)=.*$')
        set item (string split -m 1 = $line)
        set chars_to_remove "'\""
        set first_char (echo $item[2] | grep -o "[$chars_to_remove]" | head -1)
        set item[2] (echo $item[2] | string trim --chars=$first_char)
        set $options $item[1] $item[2]
        echo "Exported key $item[1] with value $item[2] and options $options"
    end
end
