# my_shell_utils
Repo with helpful scripts for different shell environments

## envsource
This fish script is used to source environment variables from a POSIX dotenv file. It is useful when you have a POSIX file
with environment variables written for bash/zsh shells and you want to source them in your current fish shell.\
Usage: `envsource <path/to/env> [options]`\
Options:

    -e: Deletes the variable from the shell environment.\
    -g: Assigns the value of the variable to the shell variable and gives it the global scope.\
    -l: Assigns the value of the variable to the shell variable and gives it the local scope.\
    -p: Causes the values to be prepended to the current set of values for the variable. This can be used with --append to both append and prepend at the same time.\
    -q: Does not display the variable and its value.\
    -u: Causes the variable to NOT be exported to child processes.\
    -U: Sets the variable as a universal variable.\

## auto_killer
The Auto Killer Script is designed to monitor and manage system resources by automatically terminating processes that exceed specified CPU and RAM usage thresholds. It's particularly useful for maintaining system stability and performance in environments where processes may occasionally consume excessive resources.
Features

* Resource Monitoring: Continuously monitors total system RAM and average CPU usage per core.
* Automatic Intervention: Automatically terminates the highest consuming process when system resource usage exceeds predefined thresholds.
* Configurable: Allows setting custom thresholds for RAM and CPU usage, and the number of CPU cores to consider.
* Systemd Integration: Comes with a systemd service file for easy management as a system service, ensuring the script runs continuously in the background.

Requirements

    A Unix-like operating system with systemd
    Dash (/bin/dash) installed
    Sufficient permissions to create and manage systemd service files

Installation

Script Setup:
Place the auto_killer.dash script in your desired directory, for example, /home/user/dev/utils/.
Make sure the script is executable:

    chmod +x /path/to/auto_killer.dash|bash|fish

Systemd Service Setup:

Copy the dash_auto_killer.service file to /etc/systemd/system/:

    sudo cp /path/to/dash_auto_killer.service /etc/systemd/system/

Edit the dash_auto_killer.service file to ensure the ExecStart path matches the location of your auto_killer.dash script.
Reload the systemd manager configuration:

    sudo systemctl daemon-reload

Enable the service to start at boot:

    sudo systemctl enable dash_auto_killer.service

Start the service immediately:

    sudo systemctl start dash_auto_killer.service

Usage:

You can manually start, stop, or check the status of the Auto Killer service using the systemctl command:

    Start: sudo systemctl start dash_auto_killer.service
    Stop: sudo systemctl stop dash_auto_killer.service
    Status: sudo systemctl status dash_auto_killer.service

Or you can use the script directly:

    ./path/to/auto_killer.dash [options]

Options:

    cores: Number of CPU cores to consider for average CPU usage calculation.
    ram: Maximum allowable total RAM usage percentage.
    cpu: Maximum allowable CPU usage percentage per core.


The script will start monitoring and managing system resources based on the predefined thresholds.
You can customize the thresholds and the number of CPU cores by editing the auto_killer.dash script directly
or by passing the values as arguments when running the script manually.

Customization

To adjust resource usage thresholds or set the number of CPU cores, edit the following variables at the beginning of the auto_killer.dash script:



Caution

This script terminates processes based on resource usage thresholds. Use with caution, especially on production systems, as terminating critical processes can lead to data loss or system instability.
