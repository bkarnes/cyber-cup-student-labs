#!/usr/bin/env bash
# stop_all_labs.sh – stop and remove all containers from both Black‑Hat‑Bash and cyber‑cup‑student‑labs stacks
# Options:
#   -h|--help   Show this help message
#   --dry-run   Print the docker commands without executing them

set -euo pipefail

info() { echo -e "\033[1;34m[INFO]\033[0m $*"; }
error() { echo -e "\033[1;31m[ERROR]\033[0m $*" >&2; exit 1; }

# Parse options
DRY_RUN=false
while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help)
            cat <<'EOF'
Usage: ./stop_all_labs.sh [OPTIONS]

Options:
  -h, --help   Show this help message and exit.
  --dry-run    Print docker compose commands without executing them.
EOF
            exit 0
            ;;
        --dry-run) DRY_RUN=true; shift ;;
        *) error "Unknown option: $1" ;;
    esac
done

# Verify Docker CLI
if ! command -v docker >/dev/null 2>&1; then
    error "Docker CLI not found. Install Docker first."
fi

# Determine sudo need
if docker info >/dev/null 2>&1; then
    SUDO=""
else
    if sudo docker info >/dev/null 2>&1; then
        SUDO="sudo"
        info "Docker requires sudo – commands will be prefixed with sudo."
    else
        error "Cannot communicate with Docker daemon. Add your user to the 'docker' group or run with sudo."
    fi
fi

# Compose file locations (adjusted for typical Kali VM layout)
BHB_COMPOSE="${HOME}/Projects/Black-Hat-Bash/lab/docker-compose.yml"
STUDENT_COMPOSE="${HOME}/Projects/cyber-cup-student-labs/labs/docker-compose.yml"

# Verify files exist
[[ -f "$BHB_COMPOSE" ]]   || error "Black‑Hat‑Bash compose file not found at $BHB_COMPOSE"
[[ -f "$STUDENT_COMPOSE" ]] || error "Student‑labs compose file not found at $STUDENT_COMPOSE"

# Function to bring down a stack
bring_down() {
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

bring_down "$STUDENT_COMPOSE" "Student‑labs"
bring_down "$BHB_COMPOSE" "Black‑Hat‑Bash"

info "All lab containers have been stopped and removed."
