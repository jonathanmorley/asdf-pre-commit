#!/usr/bin/env bats

load helpers

setup_file() {
  PLUGIN_DIR="${ASDF_PLUGIN_REPO}"
  export PLUGIN_DIR
  cache_versions
}

@test "latest-stable script exists and is executable" {
  [ -f "$PLUGIN_DIR/bin/latest-stable" ]
  [ -x "$PLUGIN_DIR/bin/latest-stable" ]
}

@test "latest-stable returns a version without filter" {
  run "$PLUGIN_DIR/bin/latest-stable"
  [ "$status" -eq 0 ]
  [[ $output =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]
}

@test "latest-stable with filter 1 returns 1.x version" {
  run "$PLUGIN_DIR/bin/latest-stable" 1
  [ "$status" -eq 0 ]
  [[ $output =~ ^1\.[0-9]+\.[0-9]+$ ]]
}

@test "latest-stable with filter 2 returns 2.x version" {
  run "$PLUGIN_DIR/bin/latest-stable" 2
  [ "$status" -eq 0 ]
  [[ $output =~ ^2\.[0-9]+\.[0-9]+$ ]]
}

@test "latest-stable with filter 3 returns 3.x version" {
  run "$PLUGIN_DIR/bin/latest-stable" 3
  [ "$status" -eq 0 ]
  [[ $output =~ ^3\.[0-9]+\.[0-9]+$ ]]
}

@test "latest-stable with filter 4 returns 4.x version" {
  run "$PLUGIN_DIR/bin/latest-stable" 4
  [ "$status" -eq 0 ]
  [[ $output =~ ^4\.[0-9]+\.[0-9]+$ ]]
}

@test "latest-stable excludes prerelease versions" {
  # Ensure the output is a stable version (no alpha, beta, rc, etc.)
  run "$PLUGIN_DIR/bin/latest-stable"
  [ "$status" -eq 0 ]
  # Should not contain prerelease identifiers
  [[ ! $output =~ (alpha|beta|rc|dev|canary|-) ]]
}

@test "latest-stable with non-matching filter returns empty" {
  run "$PLUGIN_DIR/bin/latest-stable" 999
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}

@test "latest-stable returns latest within major version" {
  # Get all 3.x versions and verify latest-stable returns the highest
  all_versions=$(get_cached_versions | tr ' ' '\n' | grep -E '^3\.[0-9]+\.[0-9]+$')
  expected=$(echo "$all_versions" | tail -1)

  run "$PLUGIN_DIR/bin/latest-stable" 3
  [ "$status" -eq 0 ]
  [ "$output" = "$expected" ]
}
