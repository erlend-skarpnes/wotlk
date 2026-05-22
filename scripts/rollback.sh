#!/usr/bin/env bash
# rollback.sh — undo the last applied migration for a given DB
# Usage: ./scripts/rollback.sh <world|characters|auth> [--yes]
#   --yes  skip the confirmation prompt (use for scripting/testing)

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
auto_yes="${2:-}"

if [[ -z "$db_key" ]]; then
  echo "Usage: $0 <world|characters|auth> [--yes]"
  exit 1
fi

db_var="DB_$(echo "$db_key" | tr '[:lower:]' '[:upper:]')"
db_name="${!db_var}"
migration_dir="$ROOT/sql/migrations/$db_key"

# Find the last applied migration
last=$($SSH_CMD "mysql -h$DB_HOST -P$DB_PORT -u$DB_USER -p$DB_PASS -sN -e \
  'SELECT migration FROM schema_migrations ORDER BY applied_at DESC, id DESC LIMIT 1;' $db_name" 2>/dev/null || true)

if [[ -z "$last" ]]; then
  echo "No applied migrations found in $db_name."
  exit 0
fi

# Derive the _down_ filename
down_name="${last/_up_/_down_}"
down_file="$migration_dir/$down_name"

if [[ ! -f "$down_file" ]]; then
  echo "ERROR: Down migration not found: $down_file" >&2
  exit 1
fi

echo "Rolling back: $last"
echo "Running:      $down_name"

if [[ "$auto_yes" != "--yes" ]]; then
  read -rp "Proceed? [y/N] " confirm
  [[ "$confirm" =~ ^[Yy]$ ]] || { echo "Aborted."; exit 0; }
fi

$SSH_CMD "mysql -h$DB_HOST -P$DB_PORT -u$DB_USER -p$DB_PASS $db_name" < "$down_file"
$SSH_CMD "mysql -h$DB_HOST -P$DB_PORT -u$DB_USER -p$DB_PASS -e \
  \"DELETE FROM schema_migrations WHERE migration = '$last';\" $db_name"

echo "✓ Rolled back $last"
