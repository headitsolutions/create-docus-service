#!/bin/bash

# Replace "your-service-name" with the desired name for your service
SERVICE_NAME="docus"

# Replace "/path/to/your/service" with the actual path to your service executable
SERVICE_PATH="/usr/bin/dotnet /var/www/api/Docus.WebApi.Host.dll --environment Release"

# Replace "your-username" with your username (the user who will run the service)
SERVICE_USER="root"

# Replace "/path/to/log/file.log" with the path to the log file for your service
LOG_FILE="/var/log/docus.log"

# Create a service file in the systemd directory
SERVICE_FILE="/etc/systemd/system/$SERVICE_NAME.service"

# Check if the service already exists
if systemctl list-unit-files | grep -q "$SERVICE_NAME.service"; then
    echo "Service $SERVICE_NAME already exists."
    exit 0
fi

# Write the service unit file
cat > $SERVICE_FILE <<EOF
[Unit]
Description=Docus

[Service]
ExecStart=$SERVICE_PATH
WorkingDirectory=/var/www/api/
SyslogIdentifier=$SERVICE_NAME
User=$SERVICE_USER

Environment=DOTNET_ROOT=/usr/lib64/dotnet

# Always restart the service
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
EOF

# Set correct permissions for the service file
chmod 644 $SERVICE_FILE

# Reload systemd daemon
systemctl daemon-reload

# Enable the service to start on boot
systemctl enable $SERVICE_NAME

# Start the service
systemctl start $SERVICE_NAME

# Check the status of the service
systemctl status $SERVICE_NAME

# View the service log
journalctl -u $SERVICE_NAME -f
