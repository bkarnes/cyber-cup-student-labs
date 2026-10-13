#!/usr/bin/env bash
# list_labs.sh – Print a markdown table of all Docker lab containers and their IPs
# Usage: ./list_labs.sh [--no-start] [-h|--help]

set -euo pipefail

usage() {
    cat <<EOF
Usage: ${0##*/} [OPTIONS]

Options:
  -h, --help        Show this help message and exit.
  --no-start        Do not run docker-compose up; assume containers are already running.
EOF
    exit 0
}

NO_START=false
while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help) usage ;;
        --no-start) NO_START=true; shift ;;
        *) echo "Unknown option: $1" >&2; usage ;;
    esac
done

collect_info() {
    local compose_file=$1
    local project_name=$2
    if ! $NO_START; then
        docker compose -f "$compose_file" up -d >/dev/null 2>&1
    fi
    docker compose -f "$compose_file" config --services | while read -r service; do
        cid=$(docker compose -f "$compose_file" ps -q "$service" || true)
        if [[ -z "$cid" ]]; then
            continue
        fi
        # Use Docker's network‑name aware format: container name + "network:IP" pairs
        raw=$(docker inspect -f '{{ .Name }} {{range $net,$conf := .NetworkSettings.Networks}}{{$net}}:{{$conf.IPAddress}} {{end}}' "$cid")
        # Build readable network→IP list with awk
        readable=$(echo "$raw" | awk -v proj="$project_name" -v svc="$service" '
            {
                container=$1;
                out="";
                for(i=2;i<=NF;i++) {
                    split($i, parts, ":");
                    if(parts[2] != "") {
                        out = out (out==""?"":", ") parts[1] " → " parts[2];
                    }
                }
                printf "| %s | %s | %s | %s |\n", proj, svc, substr(container,2), out;
            }
        ')
        echo "$readable"
    done
}

# Print markdown header
printf "| Project | Service | Container | Networks (IP) |\n"
printf "|---------|---------|-----------|----------------|\n"

# Student labs (adjusted for actual repo name)
collect_info "$HOME/Projects/cyber-cup-student-labs/labs/docker-compose.yml" "student‑labs"
# Black‑Hat‑Bash labs (external path)
BHBDIR="$HOME/Projects/Black-Hat-Bash/lab"
collect_info "$BHBDIR/docker-compose.yml" "Black‑Hat‑Bash"
