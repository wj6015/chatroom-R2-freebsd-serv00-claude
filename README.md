# Chatroom 维护说明

本项目运行于 serv00 平台。

主要功能：

* 自动检测 chatroom 是否存活
* 进程异常退出后自动拉起
* 自动维护 chat.log 日志大小
* 支持邀请码登录机制
* 支持通过 cron 定时维护

---

# 编辑 crontab

```bash
export TERM=xterm
crontab -e
```

---

# 保活任务（每5分钟检测一次）

```cron
*/5 * * * * /bin/bash /home/wj60192/keepalive.sh
```

作用：

* 每5分钟检查 chatroom 是否运行
* 如果进程退出，则自动重新启动
* 启动时自动裁剪日志，防止 chat.log 无限增大

---

# 每3天自动清理日志

```cron
0 3 */3 * * /bin/bash /home/wj60192/trim_chatlog.sh
```

作用：

* 每3天凌晨3点执行一次
* 自动只保留 chat.log 最后1000行
* 防止日志长期运行后占满磁盘空间

---

# 保存并退出 crontab

如果使用 nano：

```text
Ctrl + O
回车
Ctrl + X
```

---

# 查看当前 cron 任务

```bash
crontab -l
```

正常情况下应看到：

```cron
*/5 * * * * /bin/bash /home/wj60192/keepalive.sh

0 3 */3 * * /bin/bash /home/wj60192/trim_chatlog.sh
```

---

# 邀请码管理

## 新增邀请码

编辑邀请码文件：

```bash
nano /home/wj60192/invite_codes.txt
```

保存退出即可。

---

# 重启 chatroom 使邀请码生效

推荐方式：

```bash
pkill chatroom
```

然后手动执行：

```bash
/home/wj60192/keepalive.sh
```

也可以等待最多5分钟，由 cron 自动拉起。

---

# trim_chatlog.sh

```bash
#!/bin/bash

LOG_FILE="/home/wj60192/chat.log"

if [ -f "$LOG_FILE" ]; then
    tail -n 1000 "$LOG_FILE" > "${LOG_FILE}.tmp"
    mv "${LOG_FILE}.tmp" "$LOG_FILE"
fi
```

---

# keepalive.sh

```bash
#!/bin/bash

APP_DIR="/home/wj60192"
APP_NAME="chatroom"
LOG_FILE="$APP_DIR/chat.log"

if ! pgrep -f "/home/wj60192/chatroom" > /dev/null; then
    cd "$APP_DIR" || exit 1

    if [ -f "$LOG_FILE" ]; then
        tail -n 5000 "$LOG_FILE" > "${LOG_FILE}.tmp"
        mv "${LOG_FILE}.tmp" "$LOG_FILE"
    fi

    nohup "./$APP_NAME" >> "$LOG_FILE" 2>&1 &
fi
```

### 聊天室反向代理配置 (Cloudflare Worker)

为了绕过domain.serv00.net域名被墙并解决 WebSocket 握手问题，使用了以下 Cloudflare Worker 代码进行反向代理：

```javascript
export default {
  async fetch(request, env, ctx) {
    const targetUrl = "https://wj60192.serv00.net"; // 你的源站域名
    const url = new URL(request.url);
    url.hostname = new URL(targetUrl).hostname;
    
    // 创建一个新的请求，强制修改 Host 和 Origin 以通过源站校验
    const newRequest = new Request(url, request);
    newRequest.headers.set('Host', 'wj60192.serv00.net');
    newRequest.headers.set('Origin', 'https://wj60192.serv00.net');
    
    return fetch(newRequest);
  },
};
