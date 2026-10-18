#!/usr/bin/env bash
# Deploy the Lesotho Data Exchange-branded Central Server admin jar.
# Usage: sudo ./deploy-lesotho-ui.sh          (deploy)
#        sudo ./deploy-lesotho-ui.sh rollback (restore the original X-Road jar)
set -euo pipefail

JLIB=/usr/share/xroad/jlib
TARGET=$JLIB/centralserver-admin-service-1.0.jar
BACKUP=$JLIB/centralserver-admin-service-1.0.jar.orig-xroad
BUILT_DIR="$(dirname "$(readlink -f "$0")")/src/central-server/admin-service/application/build/libs"

if [[ "${1:-}" == "rollback" ]]; then
  [[ -f $BACKUP ]] || { echo "No backup at $BACKUP"; exit 1; }
  cp -p "$BACKUP" "$TARGET"
  systemctl restart xroad-center
  echo "Rolled back to original jar; xroad-center restarted."
  exit 0
fi

BUILT=$(ls -t "$BUILT_DIR"/*.jar 2>/dev/null | grep -v -- '-plain' | head -1 || true)
[[ -n $BUILT ]] || { echo "No built jar found in $BUILT_DIR"; exit 1; }
unzip -l "$BUILT" 'BOOT-INF/classes/public/index.html' >/dev/null 2>&1 || { echo "Built jar has no UI bundled: $BUILT"; exit 1; }

[[ -f $BACKUP ]] || cp -p "$TARGET" "$BACKUP"
install -o root -g root -m 0644 "$BUILT" "$TARGET"
systemctl restart xroad-center
echo "Deployed $BUILT -> $TARGET (backup: $BACKUP)"
echo "Waiting for xroad-center to come up..."
for _ in $(seq 1 60); do
  systemctl is-active --quiet xroad-center && curl -sk -o /dev/null https://localhost:4000/ && { echo "UI is up: https://$(hostname -f):4000/"; exit 0; }
  sleep 2
done
echo "xroad-center not responding yet; check: journalctl -u xroad-center -n 100"
