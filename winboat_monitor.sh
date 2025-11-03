#!/bin/sh

# Configuration variables
RDP_PROCESS_NAME="^xfreerdp"
APP_PROCESS_NAME="winboat"
DOCKER_CONTAINER_NAME="WinBoat"
TIMEOUT=300 # 5 minutes

# State variables
LAST_SEEN_TIME=0
RUNNING=true

# Function to stop the container
stop_container() {
    echo "Timeout reached. Stopping container $DOCKER_CONTAINER_NAME."
    docker container stop "$DOCKER_CONTAINER_NAME"
    RUNNING=false
}

# Function to wait for the container to start
wait_for_container() {
    echo "Container $DOCKER_CONTAINER_NAME is not running. Waiting for it to start."
    while true; do
        sleep 60
        if docker inspect --format='{{.State.Running}}' "$DOCKER_CONTAINER_NAME" 2>/dev/null | grep -q "true"; then
            echo "Container $DOCKER_CONTAINER_NAME has started. Resuming monitoring."
            LAST_SEEN_TIME=0
            RUNNING=true
            break
        fi
    done
}

echo "winboat_monitor is starting with PID: $$ at $(date)"

# Main loop
while $RUNNING; do
    # Check if the container is running.
    if ! docker inspect --format='{{.State.Running}}' "$DOCKER_CONTAINER_NAME" 2>/dev/null | grep -q "true"; then
        wait_for_container
        continue # Restart the loop to re-check the container status
    fi

    # Check if either of the processes are running inside the container
    # The `-q` flag for pgrep makes it quiet, returning 0 on success.
    pgrep -x "$APP_PROCESS_NAME" >/dev/null || pgrep "$RDP_PROCESS_NAME" >/dev/null
    PROCESS_RUNNING=$?

    if [ "$PROCESS_RUNNING" -eq 0 ]; then
        # At least one process is running. Reset the timer.
        if [ "$LAST_SEEN_TIME" -ne 0 ]; then
            echo "Processes detected. Timer reset."
            LAST_SEEN_TIME=0
        fi
    else
        # No monitored processes are running.
        if [ "$LAST_SEEN_TIME" -eq 0 ]; then
            # First time no processes are seen. Start the timer.
            LAST_SEEN_TIME=$(date +%s)
            echo "All monitored processes are down. Starting $TIMEOUT second timeout."
        fi

        CURRENT_TIME=$(date +%s)
        ELAPSED_TIME=$((CURRENT_TIME - LAST_SEEN_TIME))

        echo "Processes have been down for $ELAPSED_TIME seconds..."

        if [ "$ELAPSED_TIME" -ge "$TIMEOUT" ]; then
            stop_container
            wait_for_container
        fi
    fi

    sleep 5
done

