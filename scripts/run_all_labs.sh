#!/usr/bin/env bash
# run_all_labs.sh – start both Black‑Hat‑Bash and cyber‑cup‑student‑labs Docker stacks
# Options:
#   --no-build    : skip image builds (use existing images)
#   --stop        : stop and remove all containers for both stacks
#   --status      : show container status for both stacks
#   --logs        : after starting, tail logs from all containers (press Ctrl‑C to exit)
#   --dry-run     : print the commands that would be run, but do not execute them
#   -h|--help     : display this help message

set -euo pipefail

# ---------- Helper functions ------------------------------------------------
info()  { echo -e "\033[1;34m[INFO]\033[0m $*"; }
warn()  { echo -e "\033[1;33m[WARN]\033[0m $*"; }
error() { echo -e "\033[1;31m[ERROR]\033[0m $*" >&2; exit 1; }

# ---------- Option parsing ---------------------------------------------------
NO_BUILD=false
DO_STOP=false
SHOW_STATUS=false
SHOW_LOGS=false
DRY_RUN=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help)
            cat <<'EOF'
Usage: ./run_all_labs.sh [OPTIONS]

Options:
  --no-build    Skip building images (just "docker compose up -d").
  --stop        Stop and remove all containers for both stacks.
  --status      Show container status for both stacks.
  --logs        After start, tail logs from all containers.
  --dry-run     Print commands without executing.
  -h, --help    Show this help message.
EOF
            exit 0
            ;;
        --no-build)   NO_BUILD=true; shift ;;
        --stop)       DO_STOP=true; shift ;;
        --status)     SHOW_STATUS=true; shift ;;
        --logs)       SHOW_LOGS=true; shift ;;
        --dry-run)    DRY_RUN=true; shift ;;
        *)            error "Unknown option: $1" ;;
    esac
done

# ---------- Prerequisite checks ---------------------------------------------
if ! command -v docker >/dev/null 2>&1; then
    error "Docker CLI not found. Install Docker and ensure it is in your PATH."
fi

# Determine if we need sudo to talk to Docker
if docker info >/dev/null 2>&1; then
    SUDO=""
else
    if sudo docker info >/dev/null 2>&1; then
        SUDO="sudo"
        info "Docker requires sudo – commands will be prefixed with sudo."
    else
        error "Cannot communicate with Docker daemon. Are you in the 'docker' group? Or run the script with sudo."
    fi
fi

# ---------- Compose file locations ------------------------------------------
BHB_COMPOSE="${HOME}/Projects/Black-Hat-Bash/lab/docker-compose.yml"
STUDENT_COMPOSE="${HOME}/Projects/cyber-cup-student-labs/labs/docker-compose.yml"

[[ -f "$BHB_COMPOSE" ]] || error "Black‑Hat‑Bash compose file not found at $BHB_COMPOSE"
[[ -f "$STUDENT_COMPOSE" ]] || error "Student‑labs compose file not found at $STUDENT_COMPOSE"

# ---------- Core actions -----------------------------------------------------
run_up() {
    local compose=$1
    local label=$2
    local cmd="${SUDO} docker compose -f \"$compose\" up -d"
    if ! $NO_BUILD; then
        cmd="${SUDO} docker compose -f \"$compose\" up -d --build"
    fi
    if $DRY_RUN; then
        echo "[DRY‑RUN] $cmd"
    else
        info "Starting $label stack..."
        eval "$cmd"
    fi
}

run_down() {
    local compose=$1
    local label=$2
    local cmd="${SUDO} docker compose -f \"$compose\" down"
    if $DRY_RUN; then
        echo "[DRY‑RUN] $cmd"
    else
        info "Stopping $label stack..."
        eval "$cmd"
    fi
}

run_status() {
    local compose=$1
    local label=$2
    local cmd="${SUDO} docker compose -f \"$compose\" ps"
    if $DRY_RUN; then
        echo "[DRY‑RUN] $cmd"
    else
        echo "=== $label stack status ==="
        eval "$cmd"
        echo
    fi
}

# Wait for all containers in a compose file to become healthy (or have no healthcheck)
wait_healthy() {
    local compose=$1
    local label=$2
    local timeout=180   # seconds
    local interval=5
    local elapsed=0

    info "Waiting for $label containers to become healthy…"
    while true; do
        # Get all container IDs belonging to this compose project
        mapfile -t ids < <(${SUDO} docker compose -f "$compose" ps -q)
        all_good=true
        for cid in "${ids[@]}"; do
            # If a container has no healthcheck, .State.Health will be empty – treat as good
            health=$(${SUDO} docker inspect -f '{{if .State.Health}}{{.State.Health.Status}}{{else}}none{{end}}' "$cid")
            if [[ "$health" == "starting" || "$health" == "unhealthy" ]]; then
                all_good=false
                break
            fi
        done
        if $all_good; then
            info "$label containers are healthy (or have no healthcheck)."
            return 0
        fi
        (( elapsed += interval ))
        if (( elapsed >= timeout )); then
            warn "$label containers did not become healthy within $timeout seconds. Continuing anyway."
            return 1
        fi
        sleep $interval
    done
}

# ---------- Main flow --------------------------------------------------------
if $DO_STOP; then
    run_down "$STUDENT_COMPOSE" "Student‑labs"
    run_down "$BHB_COMPOSE" "Black‑Hat‑Bash"
    exit 0
fi

if $SHOW_STATUS; then
    run_status "$STUDENT_COMPOSE" "Student‑labs"
    run_status "$BHB_COMPOSE" "Black‑Hat‑Bash"
    exit 0
fi

# Normal start path
run_up "$STUDENT_COMPOSE" "Student‑labs"
run_up "$BHB_COMPOSE" "Black‑Hat‑Bash"

# Wait for healthchecks (if defined)
wait_healthy "$STUDENT_COMPOSE" "Student‑labs" || true
wait_healthy "$BHB_COMPOSE" "Black‑Hat‑Bash" || true

if $SHOW_LOGS; then
    info "Tailing logs for both stacks (Ctrl‑C to exit)…"
    # Run logs in background for each stack, then wait for both
    ${SUDO} docker compose -f "$STUDENT_COMPOSE" logs -f &
    LOG_PID1=$!
    ${SUDO} docker compose -f "$BHB_COMPOSE" logs -f &
    LOG_PID2=$!
    # Wait for any of them to exit (e.g., Ctrl‑C) and clean up the other
    wait -n
    kill $LOG_PID1 $LOG_PID2 2>/dev/null || true
fi

info "All done. Use '--status' to view containers or '--stop' to shut everything down."
