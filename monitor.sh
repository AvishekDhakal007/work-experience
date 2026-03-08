#!/bin/bash

SERVICE="nginx"
LOGFILE="/var/log/web_monitor.log"
WEBHOOK="https://discord.com/api/webhooks/1480069139853869099/exRh3P_jwebiPYt-XSKF5ac3N3tHzS25TGXBUl_hu0siAQcQYajMOgYgHtA_0NFb1lQH"

DATE=$(date '+%Y-%m-%d %H:%M:%S')

# Check if service is running
if systemctl is-active --quiet $SERVICE
then
    echo "$DATE - $SERVICE is healthy" >> $LOGFILE
else
    echo "$DATE - $SERVICE is DOWN. Restarting..." >> $LOGFILE
    
    # Restart service
    systemctl restart $SERVICE

    # Send notification to Discord
    curl -H "Content-Type: application/json" \
    -X POST \
    -d "{\"content\": \"🚨 ALERT: $SERVICE was DOWN and has been restarted at $DATE\"}" \
    $WEBHOOK
fi
