#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
mkdir -p "$ROOT/build/test-results"
run_check() {
  local name="$1"
  shift
  bash "$ROOT/tools/godot.sh" "$@" 2>&1 | tee "$ROOT/build/test-results/$name.log"
  # Godot can exit zero despite a script error. Treat its diagnostics as failures.
  if grep -Eq 'SCRIPT ERROR:|ERROR:|FAIL:' "$ROOT/build/test-results/$name.log"; then
    return 1
  fi
}
run_check import --headless --editor --import
run_check art-contract --headless --script res://tests/test_art_import.gd
run_check enemy-art-sources --headless --script res://tests/test_enemy_art_sources.gd
run_check startup --headless --quit-after 10
for ticks in 30 60 120; do
  run_check "physics-$ticks" --headless --fixed-fps "$ticks" \
    --script res://tests/run_tests.gd -- "--ticks=$ticks"
  run_check "gameplay-$ticks" --headless --fixed-fps "$ticks" \
    --script res://tests/test_gameplay.gd -- "--ticks=$ticks"
  run_check "traversal-$ticks" --headless --fixed-fps "$ticks" \
    --script res://tests/test_traversal.gd -- "--ticks=$ticks"
  run_check "enemies-$ticks" --headless --fixed-fps "$ticks" \
    --script res://tests/test_enemies.gd -- "--ticks=$ticks"
  run_check "boss-$ticks" --headless --fixed-fps "$ticks" \
    --script res://tests/test_boss.gd -- "--ticks=$ticks"
  run_check "combat-room-$ticks" --headless --fixed-fps "$ticks" \
    --script res://tests/test_combat_room.gd -- "--ticks=$ticks"
  run_check "combat-victory-$ticks" --headless --fixed-fps "$ticks" \
    --script res://tests/test_combat_victory.gd -- "--ticks=$ticks"
done
