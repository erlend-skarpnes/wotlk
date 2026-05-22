#!/usr/bin/env bash
# deploy.sh — apply pending SQL migrations to a DB, then optionally sync configs
# Usage: ./scripts/deploy.sh <world|characters|auth|--all>

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Load env
if [[ -f "$ROOT/.env" ]]; then
  # shellcheck disable=SC1091
  set -a; source "$ROOT/.env"; set +a
else
  echo "ERROR: .env not found. Copy .env.example to .env and fill it in." >&2
  exit 1
fi

SSH_CMD="ssh ${SSH_USER}@${SSH_HOST}${SSH_KEY:+ -i $SSH_KEY}"

run_migrations() {
  local db_key="$1"          # world | characters | auth
  local db_name db_var
  db_var="DB_$(echo "$db_key" | tr '[:lower:]' '[:upper:]')"
  db_name="${!db_var}"
  local migration_dir="$ROOT/sql/migrations/$db_key"

  if [[ ! -d "$migration_dir" ]]; then
    echo "No migration dir for '$db_key' — skipping."
    return
  fi

  echo "==> Ensuring schema_migrations table exists in $db_name..."
  $SSH_CMD "mysql -h$DB_HOST -P$DB_PORT -u$DB_USER -p$DB_PASS $db_name" <<'SQL'
CREATE TABLE IF NOT EXISTS `schema_migrations` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `migration` VARCHAR(255) NOT NULL UNIQUE,
  `applied_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
);
SQL

  local applied
  applied=$($SSH_CMD "mysql -h$DB_HOST -P$DB_PORT -u$DB_USER -p$DB_PASS -sN -e \
    'SELECT migration FROM schema_migrations;' $db_name")

  local pending=()
  while IFS= read -r -d '' f; do
    local name
    name="$(basename "$f")"
    if [[ "$name" == *_up_* ]] && ! grep -qxF "$name" <<< "$applied"; then
      pending+=("$f")
    fi
  done < <(find "$migration_dir" -name '*_up_*.sql' -print0 | sort -z)

  if [[ ${#pending[@]} -eq 0 ]]; then
    echo "  Nothing to apply for $db_key."
    return
  fi

  for f in "${pending[@]}"; do
    local name
    name="$(basename "$f")"
    echo "  Applying $name..."
    $SSH_CMD "mysql -h$DB_HOST -P$DB_PORT -u$DB_USER -p$DB_PASS $db_name" < "$f"
    $SSH_CMD "mysql -h$DB_HOST -P$DB_PORT -u$DB_USER -p$DB_PASS -e \
      \"INSERT IGNORE INTO schema_migrations (migration) VALUES ('$name');\" $db_name"
    echo "  ✓ $name"
  done
}

sync_configs() {
  echo "==> Syncing configs..."
  rsync -av --delete \
    "$ROOT/config/" \
    "${SSH_USER}@${SSH_HOST}:${AC_PATH}/env/dist/etc/"
  echo "  ✓ Configs synced"
}

case "${1:-}" in
  world|characters|auth)
    run_migrations "$1"
    ;;
  --all)
    run_migrations world
    run_migrations characters
    sync_configs
    ;;
  *)
    echo "Usage: $0 <world|characters|auth|--all>"
    exit 1
    ;;
esac

echo "Done."
