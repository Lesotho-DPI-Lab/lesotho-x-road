#!/usr/bin/env bash
# Deploy the Lesotho Data Exchange-branded admin UI.
# Usage: sudo ./deploy-lesotho-ui.sh              (deploy Central Server jar)
#        sudo ./deploy-lesotho-ui.sh rollback     (restore the original Central Server jar)
#        sudo ./deploy-lesotho-ui.sh ss           (deploy Security Server UI)
#        sudo ./deploy-lesotho-ui.sh ss rollback  (restore the original Security Server jar)
#
# Security Server: uses the Gradle-built proxy-ui-api jar if present; otherwise it takes the
# installed jar and swaps in the UI built with `pnpm run build` (ui/dist). That avoids a full
# Gradle build on the server, and is only done when the installed version matches this branch.
set -euo pipefail

REPO="$(dirname "$(readlink -f "$0")")"
JLIB=/usr/share/xroad/jlib

APP=cs
if [[ "${1:-}" == "ss" || "${1:-}" == "cs" ]]; then
  APP=$1
  shift
fi

if [[ $APP == cs ]]; then
  TARGET=$JLIB/centralserver-admin-service-1.0.jar
  SERVICE=xroad-center
  BUILT_DIR=$REPO/src/central-server/admin-service/application/build/libs
else
  TARGET=$JLIB/proxy-ui-api-1.0.jar
  SERVICE=xroad-proxy-ui-api
  BUILT_DIR=$REPO/src/security-server/admin-service/application/build/libs
  UI_DIST=$REPO/src/security-server/admin-service/ui/dist
fi
BACKUP=$TARGET.orig-xroad

if [[ "${1:-}" == "rollback" ]]; then
  [[ -f $BACKUP ]] || { echo "No backup at $BACKUP"; exit 1; }
  cp -p "$BACKUP" "$TARGET"
  systemctl restart "$SERVICE"
  echo "Rolled back to original jar; $SERVICE restarted."
  exit 0
fi

[[ -f $BACKUP ]] || cp -p "$TARGET" "$BACKUP"

BUILT=$(ls -t "$BUILT_DIR"/*.jar 2>/dev/null | grep -v -- '-plain' | head -1 || true)
if [[ -z $BUILT && $APP == ss ]]; then
  [[ -f $UI_DIST/index.html ]] || { echo "No built jar in $BUILT_DIR and no UI build in $UI_DIST"; exit 1; }
  BRANCH_VERSION=$(sed -n 's/^xroadVersion=//p' "$REPO/src/gradle.properties")
  INSTALLED_VERSION=$(dpkg-query -W -f='${Version}' xroad-proxy-ui-api | cut -d- -f1)
  [[ $BRANCH_VERSION == "$INSTALLED_VERSION" ]] || {
    echo "Installed X-Road $INSTALLED_VERSION does not match branch $BRANCH_VERSION; build the jar with Gradle instead."
    exit 1
  }
  BUILT=$(mktemp --suffix=.jar)
  trap 'rm -f "$BUILT"' EXIT
  # Rebuild from the original jar, replacing only BOOT-INF/classes/public/ (nested jars stay stored).
  python3 -I - "$BACKUP" "$UI_DIST" "$BUILT" <<'EOF'
import os, sys, zipfile
src, dist, out = sys.argv[1:]
prefix = 'BOOT-INF/classes/public/'
with zipfile.ZipFile(src) as zin, zipfile.ZipFile(out, 'w') as zout:
    for item in zin.infolist():
        if not item.filename.startswith(prefix):
            zout.writestr(item, zin.read(item.filename))
    zout.writestr(zipfile.ZipInfo(prefix), b'')
    for root, dirs, files in os.walk(dist):
        dirs.sort()
        rel = os.path.relpath(root, dist)
        if rel != '.':
            zout.writestr(zipfile.ZipInfo(prefix + rel + '/'), b'')
        for name in sorted(files):
            path = os.path.join(root, name)
            arc = prefix + os.path.relpath(path, dist)
            zout.write(path, arc, compress_type=zipfile.ZIP_DEFLATED)
EOF
fi
[[ -n $BUILT ]] || { echo "No built jar found in $BUILT_DIR"; exit 1; }
python3 -I -c 'import sys, zipfile; zipfile.ZipFile(sys.argv[1]).getinfo("BOOT-INF/classes/public/index.html")' "$BUILT" 2>/dev/null \
  || { echo "Built jar has no UI bundled: $BUILT"; exit 1; }

install -o root -g root -m 0644 "$BUILT" "$TARGET"
systemctl restart "$SERVICE"
echo "Deployed $BUILT -> $TARGET (backup: $BACKUP)"
echo "Waiting for $SERVICE to come up..."
for _ in $(seq 1 60); do
  systemctl is-active --quiet "$SERVICE" && curl -sk -o /dev/null https://localhost:4000/ && { echo "UI is up: https://$(hostname -f):4000/"; exit 0; }
  sleep 2
done
echo "$SERVICE not responding yet; check: journalctl -u $SERVICE -n 100"
