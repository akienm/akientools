#!/bin/bash
# setup_update.sh — install a fully automatic daily system update on an Ubuntu/Debian box.
#
#   bash setup_update.sh            # installs (uses sudo for the root parts)
#   bash setup_update.sh --run-now  # installs, then runs one update immediately as a test
#   bash setup_update.sh --uninstall
#
# Sudo: the installer asks for the sudo password once (normal sudo prompt). The 06:00 run
# needs no sudo at all — systemd runs it as root. The installer also writes
# /etc/sudoers.d/daily-auto-update so the installing user can trigger a run by hand with NO
# password, on any box:   sudo systemctl start daily-auto-update.service
#                     or: sudo /usr/local/sbin/daily-auto-update.sh
#
# What it installs:
#   /usr/local/sbin/daily-auto-update.sh          the update itself (runs as root)
#   /etc/systemd/system/daily-auto-update.service oneshot that runs it
#   /etc/systemd/system/daily-auto-update.timer   fires 06:00 daily; Persistent=true, so a
#                                                 box that was off at 06:00 runs at next boot
# Each run: apt update / full-upgrade / autoremove / autoclean, snap refresh, flatpak update +
# unused cleanup, fwupd metadata refresh (firmware is REPORTED, never applied). No prompts,
# existing config files kept on conflicts. Never reboots — the log says REBOOT REQUIRED instead.
# Log: $HOME/<hostname>/logs/updates.log of the user who ran this installer, overwritten each run.
set -e

OWNER=${SUDO_USER:-$USER}
OWNER_HOME=$(getent passwd "$OWNER" | cut -d: -f6)
SUDO=; [ "$(id -u)" = 0 ] || SUDO=sudo

if [ "$1" = --uninstall ]; then
  $SUDO systemctl disable --now daily-auto-update.timer 2>/dev/null || true
  $SUDO rm -f /usr/local/sbin/daily-auto-update.sh /etc/sudoers.d/daily-auto-update \
              /etc/systemd/system/daily-auto-update.service /etc/systemd/system/daily-auto-update.timer
  $SUDO systemctl daemon-reload
  echo "daily-auto-update removed (logs left in place)."
  exit 0
fi

command -v apt-get >/dev/null || { echo "apt-get not found — this installer is for Ubuntu/Debian." >&2; exit 1; }

# ---------------------------------------------------------------- the update script
$SUDO tee /usr/local/sbin/daily-auto-update.sh >/dev/null <<EOF
#!/bin/bash
# Daily unattended update. Installed by akientools/installers/setup_update.sh.
# Runs as root from daily-auto-update.timer (06:00). Log overwritten each run.
LOG_OWNER=$OWNER
LOG_HOME=$OWNER_HOME
EOF
$SUDO tee -a /usr/local/sbin/daily-auto-update.sh >/dev/null <<'EOF'
HOST=$(hostname)
LOGDIR=$LOG_HOME/$HOST/logs
LOG=$LOGDIR/updates.log
mkdir -p "$LOGDIR"
exec >"$LOG" 2>&1
export DEBIAN_FRONTEND=noninteractive NEEDRESTART_MODE=a APT_LISTCHANGES_FRONTEND=none
APT="apt-get -y -o DPkg::Lock::Timeout=900 -o Dpkg::Options::=--force-confdef -o Dpkg::Options::=--force-confold"
declare -A RESULT
ORDER=()
step() {  # step <name> <command...>; skipped if the tool isn't installed
  local name=$1; shift
  ORDER+=("$name")
  echo; echo "=================== $name — $(date '+%F %T') ==================="
  if ! command -v "$1" >/dev/null; then echo "($1 not installed — skipped)"; RESULT[$name]=skip; return; fi
  echo "\$ $*"
  "$@"; local rc=$?
  RESULT[$name]=$rc
  echo "--- $name exit code: $rc"
}
echo "Daily auto-update on $HOST — started $(date '+%F %T %Z')"
step "apt update"        $APT update
step "apt full-upgrade"  $APT full-upgrade
step "apt autoremove"    $APT autoremove --purge
step "apt clean"         $APT autoclean
step "snap refresh"      snap refresh
step "flatpak update"    flatpak update -y --noninteractive
step "flatpak cleanup"   flatpak uninstall -y --unused --noninteractive
step "firmware refresh"  fwupdmgr refresh --force
if command -v fwupdmgr >/dev/null; then
  echo; echo "=================== firmware available (report only, not applied) ==================="
  fwupdmgr get-updates --no-unreported-check 2>&1 || true
fi
chown -R "$LOG_OWNER": "$LOG_HOME/$HOST"
echo; echo "=================== SUMMARY ==================="
FAIL=0
for n in "${ORDER[@]}"; do
  rc=${RESULT[$n]}
  # fwupdmgr refresh returns 2 when metadata is already current — not a failure
  if [ "$rc" = 0 ] || { [ "$n" = "firmware refresh" ] && [ "$rc" = 2 ]; }; then s=OK
  elif [ "$rc" = skip ]; then s="skipped (not installed)"
  else s="FAILED (rc=$rc)"; FAIL=1; fi
  printf '  %-18s %s\n' "$n" "$s"
done
if [ -f /var/run/reboot-required ]; then
  echo "  REBOOT REQUIRED — not rebooting automatically. Packages:"
  sed 's/^/    /' /var/run/reboot-required.pkgs 2>/dev/null
else
  echo "  No reboot required."
fi
echo "Finished $(date '+%F %T %Z') — overall: $([ $FAIL = 0 ] && echo SUCCESS || echo 'COMPLETED WITH FAILURES')"
exit $FAIL
EOF
$SUDO chmod 755 /usr/local/sbin/daily-auto-update.sh

# ---------------------------------------------------------------- systemd units
$SUDO tee /etc/systemd/system/daily-auto-update.service >/dev/null <<'EOF'
[Unit]
Description=Daily unattended system update (apt, snap, flatpak, firmware metadata)
Wants=network-online.target
After=network-online.target

[Service]
Type=oneshot
ExecStart=/usr/local/sbin/daily-auto-update.sh
TimeoutStartSec=3h
Nice=10
EOF
$SUDO tee /etc/systemd/system/daily-auto-update.timer >/dev/null <<'EOF'
[Unit]
Description=Run daily-auto-update at 06:00

[Timer]
OnCalendar=*-*-* 06:00:00
Persistent=true
AccuracySec=1min

[Install]
WantedBy=timers.target
EOF

# ---------------------------------------------------------------- sudo pre-approval
# Exactly the commands that start an update; nothing broader. Validated before install,
# because a broken sudoers file locks sudo out entirely.
SYSTEMCTL=$(command -v systemctl)
SUDOERS_TMP=$(mktemp)
cat >"$SUDOERS_TMP" <<EOF
# Installed by akientools/installers/setup_update.sh — lets $OWNER start the daily update
# by hand without a password. Remove with: setup_update.sh --uninstall
$OWNER ALL=(root) NOPASSWD: $SYSTEMCTL start daily-auto-update.service, $SYSTEMCTL start --no-block daily-auto-update.service, /usr/local/sbin/daily-auto-update.sh
EOF
if $SUDO visudo -cf "$SUDOERS_TMP" >/dev/null; then
  $SUDO install -m 440 -o root -g root "$SUDOERS_TMP" /etc/sudoers.d/daily-auto-update
else
  echo "WARNING: generated sudoers rule failed validation — not installed." >&2
fi
rm -f "$SUDOERS_TMP"

$SUDO systemctl daemon-reload
$SUDO systemctl enable --now daily-auto-update.timer
echo "Installed. Log will be: $OWNER_HOME/$(hostname)/logs/updates.log"
systemctl list-timers daily-auto-update.timer --no-pager

if [ "$1" = --run-now ]; then
  echo "Running one update now (this can take a while)..."
  $SUDO systemctl start daily-auto-update.service && rc=0 || rc=$?
  tail -15 "$OWNER_HOME/$(hostname)/logs/updates.log"
  exit $rc
fi
