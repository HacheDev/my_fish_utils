#!/bin/bash

# Default values
num_cores=12
ram_threshold=90  # This will be the total RAM usage threshold
cpu_per_core_threshold=90 # This will be the total CPU usage threshold per core

# Parse arguments
for arg in "$@"
do
    case $arg in
        cores=*)
            num_cores="${arg#*=}"
            ;;
        ram=*)
            ram_threshold="${arg#*=}"
            ;;
        cpu=*)
            cpu_per_core_threshold="${arg#*=}"
            ;;
        *)
            echo "Unknown argument: $arg"
            exit 1
            ;;
    esac
done

# Log path
log_path='/var/log/auto_killer_log'

# Check interval in seconds
check_repeating_time=3

while true
do
    # Calculate total RAM usage using free command
    read total_ram available_ram <<< $(LC_ALL=C free | awk '/Mem:/{print $2, $7}')
    echo "Total RAM: $total_ram, Available RAM: $available_ram"

    # Calculate total RAM usage
    total_ram_usage=$((total_ram - available_ram))
    total_ram_usage_percentage=$(LC_ALL=C awk "BEGIN {printf \"%.2f\", $total_ram_usage * 100 / $total_ram}")

    echo "Total RAM usage: $total_ram_usage, Total RAM usage percentage: $total_ram_usage_percentage%"

    # Check if total RAM usage is greater than the threshold
    if (( $(echo "$total_ram_usage_percentage > $ram_threshold" | bc -l) )); then
        echo "Total RAM usage ($total_ram_usage_percentage%) exceeds threshold ($ram_threshold%). Proceeding to kill processes with highest RAM usage."

        # Find the process with the highest RAM usage
        read highest_ram_pid highest_ram_usage <<< $(ps --sort=-%mem -eo pid,%mem | awk 'NR==2 {print $1, $2}')

        # Kill the process and subprocesses
        echo "Killing process with PID $highest_ram_pid and RAM usage $highest_ram_usage and its subprocesses"
        pkill -TERM -P $highest_ram_pid
        kill -TERM $highest_ram_pid
        echo "Process $highest_ram_pid killed."
    fi

    # Calculate total CPU usage
    total_cpu_usage=$(ps -aux | awk '{sum += $3} END {print sum}')
#    total_cpu_usage_percentage_adjusted=$(LC_ALL=C awk "BEGIN {printf \"%.2f\", $total_cpu_usage / $num_cores}")
    total_cpu_usage_percentage_adjusted=$(LC_ALL=C awk -v total="$total_cpu_usage" -v cores="$num_cores" 'BEGIN {printf "%.2f", total/cores}')

    echo "Total CPU usage percentage: $total_cpu_usage%"
    echo "Total CPU usage per core: $total_cpu_usage_percentage_adjusted%"

    # Check if total CPU usage is greater than the threshold
    if (( $(echo "$total_cpu_usage_percentage_adjusted > $cpu_per_core_threshold" | bc -l) )); then
        echo "Total CPU usage per core ($total_cpu_usage_percentage_adjusted%) exceeds threshold ($cpu_per_core_threshold%). Proceeding to kill processes with highest CPU usage."

        # Find the process with the highest CPU usage
        read highest_cpu_pid highest_cpu_usage <<< $(ps --sort=-%cpu -eo pid,%cpu | awk 'NR==2 {print $1, $2}')

        # Kill the process and subprocesses
        echo "Killing process with PID $highest_cpu_pid and CPU usage $highest_cpu_usage and its subprocesses"
        pkill -TERM -P $highest_cpu_pid
        kill -TERM $highest_cpu_pid
        echo "Process $highest_cpu_pid killed."
    fi

    sleep $check_repeating_time
done
