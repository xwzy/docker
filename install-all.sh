#!/bin/bash

# Execute all shell scripts in pre directory
if [ -d "pre" ]; then
    for script in pre/*.sh; do
        if [ -f "$script" ]; then
            echo "Executing $script..."
            bash "$script"
        fi
    done
fi

# Execute all shell scripts in middleware directory
if [ -d "middleware" ]; then
    for script in middleware/*.sh; do
        if [ -f "$script" ]; then
            echo "Executing $script..."
            bash "$script"
        fi
    done
fi
