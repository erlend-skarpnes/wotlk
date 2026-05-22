#!/usr/bin/env bash
# status.sh — show applied vs pending migrations for a DB
# Usage: ./scripts/status.sh <world|characters|auth>

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

if [[ -f "$ROOT/.env" ]]; then
  set -a; source "$ROOT/.env"; set +a
else
  echo "ERROR: .env not found." >&2
  exit 1
fi

SSH_CMD="ssh ${SSH_USER}@${SSH_HOST}${SSH_KEY:+ -i $SSH_KEY}"

db_key="${1:-}"
if [[ -z "$db_key" ]]; then
  echo "Usage: $0 <world|characters|auth>"
  exit 1
fi

db_var="DB_$(echo "$db_key" | tr '[:lower:]' '[:upper:]')"
db_name="${!db_var}"
migration_dir="$ROOT/sql/migrations/$db_key"

applied=$($SSH_CMD "mysql -h$DB_HOST -P$DB_PORT -u$DB_USER -p$DB_PASS -sN -e \
  'SELECT migration FROM schema_migrations ORDER BY id;' $db_name" 2>/dev/null || true)

echo "=== Migration status: $db_key ($db_name) ==="
echo ""

if [[ ! -d "$migration_dir" ]]; then
  echo "No migration directory found."
  exit 0
fi

while IFS= read -r -d '' f; do
  name="$(basename "$f")"
  [[ "$name" != *_up_* ]] && continue
  if grep -qxF "$name" <<< "$applied"; then
    echo "  ✓ $name"
  else
    echo "  ○ $name  (pending)"
  fi
done < <(find "$migration_dir" -name '*_up_*.sql' -print0 | sort -z)
