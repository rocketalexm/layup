#!/usr/bin/env bash
# Test suite teardown - runs once after all tests

teardown_suite() {
    # Clean up temporary directory
    if [[ -n "$BATS_TMPDIR" && -d "$BATS_TMPDIR" ]]; then
        rm -rf "$BATS_TMPDIR"
    fi
    
    # Clean up any remaining mocks
    cleanup_mocks
    
    echo "# Test suite teardown complete" >&3
}