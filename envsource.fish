# Place this in your Fish functions folder to make it available immediately
# e.g. ~/.config/fish/functions/envsource.fish
# If any change is made, source this file
#sortin
# Usage: envsource <path/to/env>

function envsource
  # Check if number of args is greater than 1
    # if true, check if first argument starts with hyphen -
    # if this is also true, check if the other arguments dont start with arguments
    if test $num_of_args -ge 2 && string match -q -- - $argv[1][1] && \
        begin
        test $num_of_args -eq 2 || not string match -q -- - "$argv[2]"
        end && \
        begin
        test $num_of_args -le 2 || not string match -q -- - "$argv[2..-1]"
        end
        # if every condition was true, set options to first argument and file to the second
        set options $argv[1]
        set file $argv[2]
        echo "Im here"
        
    # Check that we are not passing only options without no file
    # so first argument can't start with a hyphen
    else if not string match -q -- - $argv[1]
        set options -gx
        echo "im here"
        set file $argv[1]
        echo $options
        echo $file

        # If we didnt pass the checks, return error
    else
        echo "Something went wrong"
        return 1
    end

    # Iterate over every line that matches the following criteria:
    # grep -v '^#' removes lines starting with the # character (i.e., comments).
    # grep -v '^\s*$' removes blank lines.
    # grep -E '^\s*(.*)=.*$' keeps lines that start with optional whitespace characters, 
    # followed by any character sequence, then an equal sign (=), and then any character sequence.
    for line in (cat $file | grep -v '^#' | grep -v '^\s*$' | grep -E '^\s*(.*)=.*$')

        # Split line between variable and value
        set item (string split -m 1 = $line)

        # Remove quotes or double quotes from values when they surround it
        # (since fish does not treat them as special chars when using set command)
        # It only removes the first of them that is found on the value
        set chars_to_remove "'\""
        set first_char (echo $item[2] | grep -o "[$chars_to_remove]" | head -1)
        set item[2] (echo $item[2] | string trim --chars=$first_char)

        # Set the shell variable with the options passed (or the default -gx)
        set $options $item[1] $item[2]
        echo "Exported key $item[1] with value $item[2] and options $options"
    end
end
