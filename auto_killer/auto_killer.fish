#!/usr/bin/env fish

# Default values
set num_cores 12
set ram_threshold 90  # This will be the total RAM usage threshold
set cpu_per_core_threshold 90 # This will be the total CPU usage threshold per core
set -gx LC_NUMERIC "C"


# Parse arguments
for arg in $argv
    switch $arg
        case '*cores=*'
            set num_cores (string replace 'cores=' '' -- $arg)
        case '*ram=*'
            set ram_threshold (string replace 'ram=' '' -- $arg)
        case '*cpu=*'
            set cpu_per_core_threshold (string replace 'cpu=' '' -- $arg)
        case '*'
            echo "Unknown argument: $arg"
            exit 1
    end
end

# Calculate CPU Usage Threshold
set cpu_threshold (math "$num_cores * $cpu_per_core_threshold")

# Log path
set log_path '/var/log/auto_killer_log'

# Check interval in seconds
set check_repeating_time 3

while true
    # Calculate total RAM usage using free command
    set mem_info (free | awk '/Mem:/{print $2, $7}')
    set total_ram (echo $mem_info | awk '{print $1}')
    set available_ram (echo $mem_info | awk '{print $2}')
    echo "Total RAM: $total_ram, Available RAM: $available_ram"

    set total_ram_usage (math "$total_ram - $available_ram")
    set total_ram_usage_percentage (math "($total_ram_usage / $total_ram) * 100")
    echo "Total RAM usage: $total_ram_usage%, Total RAM usage percentage: $total_ram_usage_percentage%"

    # Check if total RAM usage is greater than the threshold
    if test $total_ram_usage_percentage -gt $ram_threshold
        echo "Total RAM usage ($total_ram_usage_percentage%) exceeds threshold ($ram_threshold%). Proceeding to kill processes with highest RAM usage."

        # Find the process with the highest RAM usage
        set highest_ram_process (ps -aux --sort=-%mem | awk 'NR==2{print $2, $4}')
        set highest_ram_pid (echo $highest_ram_process | awk '{print $1}')
        set highest_ram_usage (echo $highest_ram_process | awk '{print $2}')

        # Kill the process and subproceses
        echo "Killing process with PID $highest_ram_pid and RAM usage $highest_ram_usage and its subprocesses"
        pkill -P -9 $highest_ram_pid
        kill -9 $highest_ram_pid
        echo "Process $highest_ram_pid killed."
    end

    # Calculate total CPU usage
    set total_cpu_usage (ps -aux | awk '{sum += $3} END {print sum}')
    set total_cpu_usage_percentage_adjusted (math "$total_cpu_usage / $num_cores")
    set total_cpu_usage_percentage_adjusted (printf "%.2f" $total_cpu_usage_percentage_adjusted)

    echo "Total CPU usage percentage: $total_cpu_usage%"
    echo "Total CPU usage per core: $total_cpu_usage_percentage_adjusted%"

    if test $total_cpu_usage_percentage_adjusted -gt $cpu_threshold
        echo "Total CPU usage per core ($total_cpu_usage_percentage_adjusted%) exceeds threshold ($cpu_per_core_threshold%). Proceeding to kill processes with highest CPU usage."

        # Find the process with the highest CPU usage
        set highest_cpu_process (ps -aux --sort=-%cpu | awk 'NR==2{print $2, $3}')
        set highest_cpu_pid (echo $highest_cpu_process | awk '{print $1}')
        set highest_cpu_usage (echo $highest_cpu_process | awk '{print $2}')

        # Kill the process
        echo "Killing process with PID $highest_cpu_pid and CPU usage $highest_cpu_usage and its subprocesses"
        pkill -P -9 $highest_cpu_pid
        kill -9 $highest_cpu_pid
        echo "Process $highest_cpu_pid killed."
    end

    sleep $check_repeating_time
end
