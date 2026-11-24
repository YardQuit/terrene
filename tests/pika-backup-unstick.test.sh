#!/usr/bin/bash
#
# Tests for build_files/sysfiles/usr/libexec/terrene-pika-backup-unstick.
#
# Usage:
#   ./tests/pika-backup-unstick.test.sh
#
# The script rewrites a history file that belongs to Pika Backup, so both of
# its halves matter. Clearing a leftover mark is what it is for. Leaving the
# file alone whenever the app runs, or whenever that cannot be told, is what
# keeps it from losing a backup that is actually in progress - so every case
# where it must stay quiet checks that the file is byte for byte the same.
#
# Every case runs with HOME in a scratch directory and a fake busctl first on
# PATH that answers the app-running question as the case needs, so nothing
# here reads or writes a real history or asks the real session bus.
#
# set -e is deliberately absent: this reports rather than aborts.
set -uo pipefail

cd "$(dirname "$0")/.." || exit 1
SCRIPT="${PWD}/build_files/sysfiles/usr/libexec/terrene-pika-backup-unstick"

WORK="$(mktemp -d)"
trap 'rm -rf "${WORK}"' EXIT

PASSED=0
FAILED=0

ok()  { printf '  ok    %s\n' "$1"; PASSED=$((PASSED + 1)); }
bad() { printf '  FAIL  %s\n' "$1"; FAILED=$((FAILED + 1)); }

# A fake busctl that answers NameHasOwner from FAKE_BUS: "false" (app not
# running), "true" (app running) or "fail" (no session bus).
mkdir -p "${WORK}/bin"
cat > "${WORK}/bin/busctl" <<'EOF'
#!/bin/bash
case "${FAKE_BUS}" in
    fail) exit 1 ;;
    *) echo "b ${FAKE_BUS}" ;;
esac
EOF
chmod +x "${WORK}/bin/busctl"

HISTORY_DIR="${WORK}/home/.var/app/org.gnome.World.PikaBackup/config/pika-backup"
HISTORY="${HISTORY_DIR}/history.json"

# write_history RUNS: a history with one backup marked running since
# 2026-11-04T17:43, holding RUNS earlier runs, and one backup not marked.
write_history() {
    local runs="$1"
    mkdir -p "${HISTORY_DIR}"
    jq -n --argjson n "${runs}" '{
        "aaaa": {
            config_version: 2,
            run: [range($n) | {end: "2026-11-04T15:08:05+01:00",
                               outcome: {Completed: {stats: {}}},
                               messages: [], include: ["/home"], exclude: []}],
            running: {start: "2026-11-04T17:43:11+01:00"},
            browsing: null,
            last_completed: null,
            last_check: null,
            suggested_exclude: {}
        },
        "bbbb": {
            config_version: 2,
            run: [{end: "2026-11-04T15:21:24+01:00",
                   outcome: {Completed: {stats: {}}},
                   messages: [], include: [], exclude: []}],
            running: null,
            browsing: null,
            last_completed: null,
            last_check: null,
            suggested_exclude: {}
        }
    }' > "${HISTORY}"
    chmod 0600 "${HISTORY}"
}

# run_script BUS: run the script as the timer does, with the fake bus answer.
run_script() {
    HOME="${WORK}/home" PATH="${WORK}/bin:${PATH}" FAKE_BUS="$1" "${SCRIPT}" >/dev/null 2>"${WORK}/stderr"
}

# expect_untouched NAME BUS: the script exits 0 and leaves the file as it was.
expect_untouched() {
    local name="$1" bus="$2"
    cp "${HISTORY}" "${WORK}/before"
    if run_script "${bus}" && cmp -s "${WORK}/before" "${HISTORY}"; then
        ok "${name}"
    else
        bad "${name}"
    fi
}

echo "Leftover marks"

write_history 3
cp "${HISTORY}" "${WORK}/before"
if run_script false; then ok "exits 0 after clearing"; else bad "exits 0 after clearing"; fi

if [ "$(jq '.aaaa.running' "${HISTORY}")" = "null" ]; then
    ok "the running mark is gone"
else
    bad "the running mark is gone"
fi

first="$(jq -c '.aaaa.run[0]' "${HISTORY}")"
expected='{"end":"2026-11-04T17:43:11+01:00","outcome":{"Aborted":"LeftRunning"},"messages":[],"include":[],"exclude":[]}'
if [ "${first}" = "${expected}" ]; then
    ok "the cut-off run is recorded as Pika Backup records it, ending when it started"
else
    bad "the cut-off run is recorded as Pika Backup records it (got ${first})"
fi

if [ "$(jq '.aaaa.run | length' "${HISTORY}")" = "4" ] \
   && [ "$(jq -r '.aaaa.run[1].include[0]' "${HISTORY}")" = "/home" ]; then
    ok "the earlier runs are kept, after the new one"
else
    bad "the earlier runs are kept, after the new one"
fi

if [ "$(jq -c '.bbbb' "${HISTORY}")" = "$(jq -c '.bbbb' "${WORK}/before")" ]; then
    ok "a backup without a mark is left as it was"
else
    bad "a backup without a mark is left as it was"
fi

if [ "$(stat -c %a "${HISTORY}")" = "600" ]; then
    ok "the file keeps its permissions"
else
    bad "the file keeps its permissions (now $(stat -c %a "${HISTORY}"))"
fi

if [ -z "$(find "${HISTORY_DIR}" -name 'history.json.*')" ]; then
    ok "no temporary file is left beside it"
else
    bad "no temporary file is left beside it"
fi

write_history 10
run_script false
if [ "$(jq '.aaaa.run | length' "${HISTORY}")" = "10" ] \
   && [ "$(jq -r '.aaaa.run[0].outcome.Aborted' "${HISTORY}")" = "LeftRunning" ]; then
    ok "a full history stays at ten runs, dropping the oldest"
else
    bad "a full history stays at ten runs, dropping the oldest"
fi

write_history 1
jq '.aaaa.running = null | .bbbb.browsing = {start: "2026-11-04T17:43:11+01:00"}' "${HISTORY}" > "${WORK}/t"
cp "${WORK}/t" "${HISTORY}"
run_script false
if [ "$(jq '.bbbb.browsing' "${HISTORY}")" = "null" ] \
   && [ "$(jq '.bbbb.run | length' "${HISTORY}")" = "1" ]; then
    ok "a leftover browsing mark is cleared without adding a run"
else
    bad "a leftover browsing mark is cleared without adding a run"
fi

echo "Staying quiet"

write_history 3
expect_untouched "the app is running: the backup may be real" true
expect_untouched "the session bus cannot be asked" fail

write_history 3
jq '.aaaa.running = null' "${HISTORY}" > "${WORK}/t" && cp "${WORK}/t" "${HISTORY}"
expect_untouched "nothing is marked" false

rm -rf "${WORK:?}/home"
if run_script false && [ ! -e "${HISTORY}" ]; then
    ok "Pika Backup is not installed"
else
    bad "Pika Backup is not installed"
fi

echo
echo "${PASSED} passed, ${FAILED} failed"
[ "${FAILED}" -eq 0 ]
