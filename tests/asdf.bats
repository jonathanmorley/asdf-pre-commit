#!/usr/bin/env bats

load helpers

setup_file() {
  PLUGIN_DIR="${ASDF_PLUGIN_REPO}"
  export PLUGIN_DIR
  cache_versions
}

# Build a test command that patches shebangs and runs pre-commit --version
get_test_command() {
  if command -v patchShebangs &>/dev/null; then
    # Patch shebangs before running pre-commit
    echo "patchShebangs bin; pre-commit --version"
  else
    echo "pre-commit --version"
  fi
}

# Helper function to test a specific major version of the plugin
# Usage: test_version <major_version>
test_version() {
  local major_version="$1"
  local version

  # Resolve latest version for this major (asdf plugin test doesn't support latest:X syntax in Go version)
  version=$("$PLUGIN_DIR/bin/latest-stable" "$major_version")
  [[ -n $version ]] || {
    echo "Failed to resolve latest v${major_version} version"
    return 1
  }

  # Remove any leftover test plugin
  asdf plugin remove "test-v${major_version}" 2>/dev/null || true

  asdf plugin test \
    "test-v${major_version}" \
    "$PLUGIN_DIR" \
    --asdf-tool-version="$version" \
    "$(get_test_command)"
}

@test "asdf plugin test v2" {
  test_version 2
}

@test "asdf plugin test v3" {
  test_version 3
}

@test "asdf plugin test v4" {
  test_version 4
}
