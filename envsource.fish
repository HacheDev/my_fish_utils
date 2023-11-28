# Place this in your Fish functions folder to make it available immediately
# e.g. ~/.config/fish/functions/envsource.fish
# If any change is made, source this file
#sortin
# Usage: envsource <path/to/env>

function envsource

    #First we save the number of arguments and the valid options of the command
    set num_of_args (count $argv)
    set valid_options b e g l p q t u U x

    # Check if number of args is 2
    # if true, check if first argument starts with hyphen - and is a valid option of set command
    # if this is also true, check if the other arguments dont start with hyphen
    if test $num_of_args -eq 2 && string match -rq -- "^-[$valid_options]" $argv[1] && ! string match -q -- "-*" $argv[2]
        # if every condition was true, set options to first argument and file to the second
        set options $argv[1]
        set file $argv[2]

    # Check that we are not passing only options without no file
    # so first argument can't start with a hyphen
    else if test $num_of_args -eq 1 && ! string match -q -- "-*" $argv[1]
        set options -gx
        set file $argv[1]

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

        # If option -e was passed, we notify we are erasing variables
        # We do this check before to avoid performing useless operations
        # the values of the env files since they wont be used
        if test "$options" = "-e"
            set $options $item[1]
            echo "Deleted variable $item[1]"

        else
            # Set the shell variable with the options passed (or the default -gx)
            set $options $item[1] $item[2]
            echo "Exported variable $item[1] with value $item[2] and options $options"
        end
    end
end
