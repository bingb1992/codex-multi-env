#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BIN="$ROOT_DIR/bin/codex-env"
TEST_ROOT="$ROOT_DIR/.tmp/smoke-root"
OUT_DIR="$ROOT_DIR/.tmp/smoke-output"
FAKE_BIN_DIR="$ROOT_DIR/.tmp/fake-bin"

rm -rf "$TEST_ROOT"
rm -rf "$OUT_DIR"
rm -rf "$FAKE_BIN_DIR"
mkdir -p "$OUT_DIR"
mkdir -p "$FAKE_BIN_DIR"

cat >"$FAKE_BIN_DIR/codex" <<'EOF'
#!/usr/bin/env bash
if [[ "${1:-}" == "--version" ]]; then
  echo "codex fake-test"
  exit 0
fi
echo "fake codex only supports --version" >&2
exit 2
EOF
chmod +x "$FAKE_BIN_DIR/codex"

bash -n "$BIN"

CODEX_MULTI_ENV_ROOT="$TEST_ROOT" "$BIN" init alpha >"$OUT_DIR/init.out"
CODEX_MULTI_ENV_ROOT="$TEST_ROOT" "$BIN" status alpha >"$OUT_DIR/status.out"
CODEX_MULTI_ENV_ROOT="$TEST_ROOT" "$BIN" list >"$OUT_DIR/list.out"
CODEX_MULTI_ENV_ROOT="$TEST_ROOT" CODEX_BIN="$FAKE_BIN_DIR/codex" "$BIN" doctor >"$OUT_DIR/doctor.out"

grep -q "created environment: alpha" "$OUT_DIR/init.out"
grep -q "CODEX_HOME=$TEST_ROOT/envs/alpha/codex-home" "$OUT_DIR/status.out"
grep -q "^alpha$" "$OUT_DIR/list.out"
grep -q "codex: $FAKE_BIN_DIR/codex" "$OUT_DIR/doctor.out"
grep -q "codex_version: codex fake-test" "$OUT_DIR/doctor.out"
grep -q "root_writable: yes" "$OUT_DIR/doctor.out"

echo "smoke ok"
