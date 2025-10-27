#!/usr/bin/env bash
# Mock helper functions for Bats tests
# Following London School TDD principles

# Track mock calls
declare -gA mock_call_count

# Mock a command with fixed output
# Usage: mock_command "command_name" "output"
mock_command() {
    local cmd="$1"
    local output="$2"
    
    eval "${cmd}() { echo '${output}'; track_mock_call '${cmd}'; }"
}

# Mock a command that fails
# Usage: mock_command_fail "command_name" [exit_code]
mock_command_fail() {
    local cmd="$1"
    local exit_code="${2:-1}"
    
    eval "${cmd}() { track_mock_call '${cmd}'; return ${exit_code}; }"
}

# Mock a command with multiple outputs (one per call)
# Usage: mock_command_sequence "command_name" "output1" "output2" "output3"
mock_command_sequence() {
    local cmd="$1"
    shift
    local -a outputs=("$@")
    
    # Store outputs in a global array with proper escaping
    eval "declare -ga mock_sequence_${cmd}=()"
    for output in "${outputs[@]}"; do
        eval "mock_sequence_${cmd}+=(\"$output\")"
    done
    
    # Create a counter file for this mock
    local counter_file="/tmp/mock_${cmd}_counter_$$"
    echo "0" > "$counter_file"
    
    # Create function that returns next output
    eval "${cmd}() {
        local counter_file=\"$counter_file\"
        local idx=\$(cat \"\$counter_file\")
        local -n arr=mock_sequence_${cmd}
        track_mock_call '${cmd}'
        echo \"\${arr[\$idx]}\"
        echo \$((idx + 1)) > \"\$counter_file\"
    }"
}

# Track mock function calls
track_mock_call() {
    local cmd="$1"
    mock_call_count[$cmd]=$((${mock_call_count[$cmd]:-0} + 1))
}

# Reset mock call tracking
reset_mock_calls() {
    mock_call_count=()
}

# Mock file operations
mock_file_exists() {
    local filepath="$1"
    eval "test() {
        if [[ \"\$1\" == \"-f\" && \"\$2\" == \"${filepath}\" ]]; then
            return 0
        fi
        command test \"\$@\"
    }"
}

mock_file_not_exists() {
    local filepath="$1"
    eval "test() {
        if [[ \"\$1\" == \"-f\" && \"\$2\" == \"${filepath}\" ]]; then
            return 1
        fi
        command test \"\$@\"
    }"
}

# Mock file reading
mock_file_content() {
    local filepath="$1"
    local content="$2"
    
    eval "cat() {
        if [[ \"\$1\" == \"${filepath}\" ]]; then
            echo '${content}'
            return 0
        fi
        command cat \"\$@\"
    }"
}

# Mock user input
mock_user_input() {
    local input="$1"
    eval "read() { 
        if [[ \"\$1\" == \"-r\" ]]; then
            eval \"\$2='${input}'\"
        else
            eval \"\$1='${input}'\"
        fi
        return 0
    }"
}

# Mock uuidgen command
mock_uuidgen() {
    local uuid="$1"
    mock_command "uuidgen" "$uuid"
}

# Mock uuidgen with sequence of values
mock_uuidgen_sequence() {
    mock_command_sequence "uuidgen" "$@"
}

# Mock date command
mock_date() {
    local timestamp="$1"
    mock_command "date" "$timestamp"
}

# Cleanup function to restore original commands
cleanup_mocks() {
    unset -f uuidgen date xmllint open cat test read 2>/dev/null || true
    reset_mock_calls
    # Clean up counter files
    rm -f /tmp/mock_*_counter_$$ 2>/dev/null || true
}