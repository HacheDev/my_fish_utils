#!/bin/bash

# Default values
num_cores=12
ram_threshold=90  # This will be the total RAM usage threshold
cpu_per_core_threshold=90 # This will be the CPU usage threshold per core

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

# Calculate CPU Usage Threshold
cpu_threshold=$((num_cores * cpu_per_core_threshold ))

# Log path
log_path='/var/log/auto_killer_log'

# Check interval in seconds
check_repeating_time=3

while true
do
    # Calculate total RAM usage
    total_ram_usage=$(ps -aux | awk '{sum += $4} END {print sum}')

    # Calculate total CPU usage
    total_cpu_usage=$(ps -aux | awk '{sum += $3} END {print sum}')

    # Check if total RAM usage is greater than the threshold
    if (( $(echo "$total_ram_usage > $ram_threshold" | bc -l) ))
    then
        echo "Total RAM usage ($total_ram_usage%) exceeds threshold ($ram_threshold%). Consider taking action."

        # Find the process with the highest RAM usage
        read highest_ram_pid highest_ram_usage <<< $(ps -aux --sort=-%mem | awk 'NR==2{print $2, $4}')

        # Kill the process
        echo "Killing process with PID $highest_ram_pid and RAM usage $highest_ram_usage%"
        kill -9 $highest_ram_pid
        echo "Process ($highest_ram_pid) killed."
    fi

    # Check if total CPU usage is greater than the threshold
    total_cpu_usage_adjusted=$(echo "$total_cpu_usage / $num_cores" | bc -l)
    if (( $(echo "$total_cpu_usage_adjusted > $cpu_per_core_threshold" | bc -l) ))
    then
        echo "Total CPU usage per core ($total_cpu_usage_adjusted%) exceeds threshold ($cpu_per_core_threshold%). Consider taking action."

        # Find the process with the highest CPU usage
        read highest_cpu_pid highest_cpu_usage <<< $(ps -aux --sort=-%cpu | awk 'NR==2{print $2, $3}')

        # Kill the process
        echo "Killing process with PID $highest_cpu_pid and CPU usage $highest_cpu_usage%"
        kill -9 $highest_cpu_pid
        echo "Process ($highest_cpu_pid) killed."
    fi

    sleep $check_repeating_time
done
