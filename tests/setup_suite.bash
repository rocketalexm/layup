#!/usr/bin/env bash
# Test suite setup - runs once before all tests

setup_suite() {
    # Export test helpers directory
    export BATS_TEST_DIRNAME="${BATS_TEST_DIRNAME:-$(dirname "${BASH_SOURCE[0]}")}"
    export HELPERS_DIR="${BATS_TEST_DIRNAME}/helpers"
    
    # Load helper functions
    source "${HELPERS_DIR}/mocks.bash"
    source "${HELPERS_DIR}/assertions.bash"
    
    # Create temporary directory for test artifacts
    export BATS_TMPDIR="${BATS_TMPDIR:-/tmp/bats-$$}"
    mkdir -p "$BATS_TMPDIR"
    
    # Set up test environment
    export TEST_ENV="test"
    
    echo "# Test suite setup complete" >&3
}