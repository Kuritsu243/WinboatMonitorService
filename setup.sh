#!/bin/sh

set -e
set -u

SERVICE_NAME=winboat_monitor.service
SCRIPT_NAME=winboat_monitor.sh
INSTALL_DIR="/usr/local/bin"
SYSTEMD_DIR="/etc/systemd/system"
TIMEOUT=300



if [ "$EUID" -ne 0 ]; then #check for root
  echo "Please run the setup script as root!"
  exit 1
fi

echo "Starting setup for the Winboat Monitor Service!"
echo "Written by Kuritsu243... I'm not liable for whatever this script does and doesn't do"

# check if required files are in the directory
if [ ! -f "$SERVICE_NAME" ]; then
  echo "$SERVICE_NAME not found in the same directory as the setup.sh! please make sure these are both in the same directory."
  exit 1
fi

if [ ! -f "$SCRIPT_NAME" ]; then
  echo "$SCRIPT_NAME not found in the same directory as the setup.sh! please make sure these are both in the same directory."
  exit 1
fi

# The --quiet flag prevents any output (like "active") from being printed.
if systemctl is-active --quiet "$SERVICE_NAME"; then
    echo "Service is running. Stopping it now..."
    # Use sudo if the script isn't already running as root
    sudo systemctl stop "$SERVICE_NAME"
    echo "Service stopped."
fi

# timeout value
echo ""
read -rp "Please enter the timeout value in seconds. This is the length of inactivity the VM needs before being shutdown by the script. (Default 300 - 5 minutes.): " TIMEOUT
TIMEOUT=${TIMEOUT:-300}
echo "Timeout length set to $TIMEOUT."


# docker container name
echo ""
read -rp "Please enter the name of the Docker container name for your windows VM (Default WinBoat): " DOCKER_CONTAINER_NAME
if [ -z "$DOCKER_CONTAINER_NAME" ]; then
  DOCKER_CONTAINER_NAME="WinBoat"
fi

# copy script if not existing
if [ ! -f "$INSTALL_DIR/$SCRIPT_NAME" ]; then
  cp "$SCRIPT_NAME" "$INSTALL_DIR/"
fi

# update timeout value in the service and bash script
sed -i "s/^TIMEOUT=.*/TIMEOUT=$TIMEOUT/" "$INSTALL_DIR/$SCRIPT_NAME" || \
  echo "TIMEOUT=$TIMEOUT" >> "$INSTALL_DIR/$SCRIPT_NAME"


# update docker name in the service and bash script
sed -i "s/^DOCKER_CONTAINER_NAME=.*/DOCKER_CONTAINER_NAME=\"$DOCKER_CONTAINER_NAME\"/" "$INSTALL_DIR/$SCRIPT_NAME" || \
  echo "DOCKER_CONTAINER_NAME=\"$DOCKER_CONTAINER_NAME\"" >> "$INSTALL_DIR/$SCRIPT_NAME"


# mark script executable
chmod +x "$INSTALL_DIR/$SCRIPT_NAME"

# copy service
echo "installing $SERVICE_NAME in $SYSTEMD_DIR"
cp "$SERVICE_NAME" "$SYSTEMD_DIR/"
chmod 644 "$SYSTEMD_DIR/$SERVICE_NAME"


# reload daemon
systemctl daemon-reload

# start service and enable on start
systemctl enable $SERVICE_NAME
systemctl restart $SERVICE_NAME

echo "Setup complete!"
echo "Check to see if the service is running by executing 'systemctl status $SERVICE_NAME'"
echo "To check logs of the service, execute 'journalctl -u $SERVICE_NAME -f'"

