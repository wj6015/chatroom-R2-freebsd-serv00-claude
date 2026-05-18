crontab -e
*/5 * * * * /bin/bash /home/wj60192/keepalive.sh
Ctrl + O
回车
Ctrl + X
crontab -l
应该看到：*/5 * * * * /bin/bash /home/wj60192/keepalive.sh

如果要新增邀请码：
nano /home/wj60192/invite_codes.txt
保存。退出。
pkill chatroom
/home/wj60192/keepalive.sh 
也可以等待最多5分钟，keepalive.sh 自动拉起。
