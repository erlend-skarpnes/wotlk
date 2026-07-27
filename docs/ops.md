# Ops Runbook

Reference for rare server infrastructure tasks (VM rebuild, crash debugging, etc.).

## Nightly Restart (cron)

The server restarts at **3am** via a cron job on the server (not tracked in this repo). If the VM is rebuilt:

```bash
ssh root@azerothcore "(crontab -l 2>/dev/null; echo '0 3 * * * /usr/bin/tmux send-keys -t world-session \"server restart 5\" Enter') | crontab -"
```

## Boot Autostart (systemd)

Both servers start automatically on boot via systemd units (not tracked in this repo).

| Unit | Controls |
|---|---|
| `acore-auth.service` | authserver in `auth-session` |
| `acore-world.service` | worldserver in `world-session` |

If the VM is rebuilt, recreate them:

```ini
# /etc/systemd/system/acore-auth.service
[Unit]
Description=AzerothCore Auth Server
After=network.target mysql.service
Wants=mysql.service

[Service]
Type=simple
User=root
WorkingDirectory=/root/azerothcore-wotlk
ExecStart=/usr/bin/tmux new-session -s auth-session './acore.sh run-authserver'
ExecStop=/usr/bin/tmux kill-session -t auth-session
RemainAfterExit=yes
Restart=no

[Install]
WantedBy=multi-user.target
```

```ini
# /etc/systemd/system/acore-world.service
[Unit]
Description=AzerothCore World Server
After=network.target mysql.service acore-auth.service
Wants=mysql.service

[Service]
Type=simple
User=root
WorkingDirectory=/root/azerothcore-wotlk
ExecStart=/usr/bin/tmux new-session -s world-session './acore.sh run-worldserver'
ExecStop=/usr/bin/tmux send-keys -t world-session 'server shutdown 5' Enter
RemainAfterExit=yes
Restart=no

[Install]
WantedBy=multi-user.target
```

```bash
systemctl daemon-reload
systemctl enable acore-auth.service acore-world.service
```

## Debugging Crashes (GDB mode)

To capture a stack trace on crash, restart with GDB enabled:

```bash
ssh root@azerothcore 'tmux send-keys -t world-session "server shutdown 5" Enter'
# wait for shutdown, then:
ssh root@azerothcore 'tmux send-keys -t world-session "bash ~/azerothcore-wotlk/apps/startup-scripts/src/simple-restarter ~/azerothcore-wotlk/env/dist/bin worldserver ~/azerothcore-wotlk/apps/startup-scripts/src/gdb.conf \"\" \"\" \"\" 1 ~/azerothcore-wotlk/env/dist/bin/crashes" Enter'
```

Stack trace is written to `~/azerothcore-wotlk/env/dist/bin/crashes/gdb-crash.txt`.

> **Note:** In GDB mode, `server restart` exits 0 and the restarter will **not** relaunch. Use `server shutdown` + manual start.

After debugging, switch back to the normal restarter:

```bash
ssh root@azerothcore 'tmux send-keys -t world-session "cd ~/azerothcore-wotlk && ./acore.sh run-worldserver" Enter'
```
