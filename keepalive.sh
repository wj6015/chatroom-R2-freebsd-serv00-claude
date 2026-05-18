#!/bin/bash

APP_DIR="/home/wj60192"
APP_NAME="chatroom"
LOG_FILE="$APP_DIR/chat.log"

if ! pgrep -x "$APP_NAME" > /dev/null; then
    cd "$APP_DIR" || exit 1

    # 日志裁剪
    if [ -f "$LOG_FILE" ]; then
        tail -n 5000 "$LOG_FILE" > "${LOG_FILE}.tmp"
        mv "${LOG_FILE}.tmp" "$LOG_FILE"
    fi

    # 启动程序
    nohup "./$APP_NAME" >> "$LOG_FILE" 2>&1 &
fi
