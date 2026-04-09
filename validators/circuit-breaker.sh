#!/bin/bash
# Circuit Breaker Validator
# Prevents infinite retry loops by tracking consecutive failures per agent
# Usage: ./circuit-breaker.sh <check|fail|success|reset|status> <agent-name>

set -e

MAX_FAILURES=3
STATE_FILE=".claude/.circuit-breaker-state"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Initialize state file if not exists
init_state() {
    if [ ! -f "$STATE_FILE" ]; then
        echo '{}' > "$STATE_FILE"
    fi
}

# Get failure count for agent
get_failures() {
    local agent=$1
    init_state
    local count=$(grep -o "\"$agent\":[0-9]*" "$STATE_FILE" 2>/dev/null | grep -o '[0-9]*' || echo "0")
    echo "${count:-0}"
}

# Set failure count for agent
set_failures() {
    local agent=$1
    local count=$2
    init_state

    if grep -q "\"$agent\":" "$STATE_FILE"; then
        sed -i "s/\"$agent\":[0-9]*/\"$agent\":$count/" "$STATE_FILE"
    else
        # Add new agent to state
        local content=$(cat "$STATE_FILE")
        if [ "$content" = "{}" ]; then
            echo "{\"$agent\":$count}" > "$STATE_FILE"
        else
            sed -i "s/}$/,\"$agent\":$count}/" "$STATE_FILE"
        fi
    fi
}

# Check if circuit is open (too many failures)
check_circuit() {
    local agent=$1
    local failures=$(get_failures "$agent")

    if [ "$failures" -ge "$MAX_FAILURES" ]; then
        echo -e "${RED}❌ CIRCUIT OPEN for $agent${NC}"
        echo -e "${YELLOW}   $failures consecutive failures. Manual intervention required.${NC}"
        echo ""
        echo "Before resetting, investigate:"
        echo "  1. Check error logs for root cause"
        echo "  2. Verify input quality (ResearchPack, Plan)"
        echo "  3. Confirm prerequisites are met"
        echo "  4. Consider if task is feasible"
        echo ""
        echo "To reset: ./circuit-breaker.sh reset $agent"
        exit 1
    else
        echo -e "${GREEN}✅ Circuit CLOSED for $agent${NC} (failures: $failures/$MAX_FAILURES)"
        exit 0
    fi
}

# Record a failure
record_failure() {
    local agent=$1
    local failures=$(get_failures "$agent")
    failures=$((failures + 1))
    set_failures "$agent" "$failures"

    if [ "$failures" -ge "$MAX_FAILURES" ]; then
        echo -e "${RED}⚠️ CIRCUIT OPENED for $agent${NC}"
        echo -e "${YELLOW}   Max failures ($MAX_FAILURES) reached. Blocking further attempts.${NC}"
        exit 1
    else
        echo -e "${YELLOW}⚠️ Failure recorded for $agent${NC} ($failures/$MAX_FAILURES)"
        exit 0
    fi
}

# Record a success (reset failures)
record_success() {
    local agent=$1
    set_failures "$agent" "0"
    echo -e "${GREEN}✅ Success recorded for $agent${NC} - circuit reset"
    exit 0
}

# Manual reset
reset_circuit() {
    local agent=$1
    set_failures "$agent" "0"
    echo -e "${GREEN}✅ Circuit manually reset for $agent${NC}"
    exit 0
}

# Show status
show_status() {
    init_state
    echo "Circuit Breaker Status:"
    echo "======================"
    cat "$STATE_FILE" | tr ',' '\n' | tr -d '{}\"' | while read line; do
        if [ -n "$line" ]; then
            agent=$(echo "$line" | cut -d: -f1)
            count=$(echo "$line" | cut -d: -f2)
            if [ "$count" -ge "$MAX_FAILURES" ]; then
                echo -e "  ${RED}$agent: $count failures (OPEN)${NC}"
            elif [ "$count" -gt "0" ]; then
                echo -e "  ${YELLOW}$agent: $count failures${NC}"
            else
                echo -e "  ${GREEN}$agent: $count failures${NC}"
            fi
        fi
    done
}

# Main
case "$1" in
    check)
        check_circuit "$2"
        ;;
    fail)
        record_failure "$2"
        ;;
    success)
        record_success "$2"
        ;;
    reset)
        reset_circuit "$2"
        ;;
    status)
        show_status
        ;;
    *)
        echo "Usage: $0 <check|fail|success|reset|status> [agent-name]"
        echo ""
        echo "Commands:"
        echo "  check <agent>   - Check if circuit is open"
        echo "  fail <agent>    - Record a failure"
        echo "  success <agent> - Record success (reset counter)"
        echo "  reset <agent>   - Manually reset circuit"
        echo "  status          - Show all circuit states"
        exit 1
        ;;
esac
