#!/usr/bin/env bash
# Deploy the Lesotho Exchange-branded Security Server admin UI.
# Swaps only the UI files (BOOT-INF/classes/public/) inside the installed jar; the backend stays the released build.
# Build first:  cd src && pnpm install --frozen-lockfile && cd security-server/admin-service/ui && pnpm run build-only
#               (set VITE_BRAND_MINISTRY=<key> to brand for a ministry other than the .env default)
# Usage: sudo ./deploy-lesotho-ss-ui.sh          (deploy)
#        sudo ./deploy-lesotho-ss-ui.sh rollback (restore the original X-Road jar)
set -euo pipefail

JLIB=/usr/share/xroad/jlib
TARGET=$JLIB/proxy-ui-api-1.0.jar
BACKUP=$JLIB/proxy-ui-api-1.0.jar.orig-xroad
DIST="$(dirname "$(readlink -f "$0")")/src/security-server/admin-service/ui/dist"

wait_for_ui() {
  echo "Waiting for xroad-proxy-ui-api to come up..."
  for _ in $(seq 1 90); do
    systemctl is-active --quiet xroad-proxy-ui-api && curl -sk -o /dev/null https://localhost:4000/ && { echo "UI is up: https://$(hostname -f):4000/"; return 0; }
    sleep 2
  done
  echo "xroad-proxy-ui-api not responding yet; check: journalctl -u xroad-proxy-ui-api -n 100"
}

if [[ "${1:-}" == "rollback" ]]; then
  [[ -f $BACKUP ]] || { echo "No backup at $BACKUP"; exit 1; }
  cp -p "$BACKUP" "$TARGET"
  systemctl restart xroad-proxy-ui-api
  echo "Rolled back to original jar; xroad-proxy-ui-api restarted."
  wait_for_ui
  exit 0
fi

[[ -f $DIST/index.html ]] || { echo "No built UI at $DIST"; exit 1; }

[[ -f $BACKUP ]] || cp -p "$TARGET" "$BACKUP"
TMP=$(mktemp "$JLIB/.proxy-ui-api.XXXXXX.jar")
trap 'rm -f "$TMP"' EXIT

# Rebuild from the pristine jar: copy every entry unchanged (keeping each entry's compression,
# so nested BOOT-INF/lib jars stay STORED for the Spring Boot loader), then add the new UI files.
python3 -I - "$BACKUP" "$TMP" "$DIST" <<'EOF'
import os, sys, zipfile
src, dst, dist = sys.argv[1:4]
prefix = 'BOOT-INF/classes/public/'
with zipfile.ZipFile(src) as zin, zipfile.ZipFile(dst, 'w') as zout:
    for info in zin.infolist():
        if info.filename.startswith(prefix):
            continue
        zout.writestr(info, zin.read(info.filename))
    zout.writestr(zipfile.ZipInfo(prefix), b'')
    for root, dirs, files in os.walk(dist):
        dirs.sort()
        rel = os.path.relpath(root, dist)
        if rel != '.':
            zout.writestr(zipfile.ZipInfo(prefix + rel + '/'), b'')
        for name in sorted(files):
            arc = prefix + (name if rel == '.' else rel + '/' + name)
            zout.write(os.path.join(root, name), arc, compress_type=zipfile.ZIP_DEFLATED)
print('UI files replaced under', prefix)
EOF

install -o root -g root -m 0644 "$TMP" "$TARGET"
systemctl restart xroad-proxy-ui-api
echo "Deployed $DIST -> $TARGET (backup: $BACKUP)"
wait_for_ui
