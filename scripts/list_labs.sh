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
        # Raw inspection: container name and each network's IP (with network ID)
        raw=$(docker inspect -f '{{ .Name }} {{range .NetworkSettings.Networks}}{{.NetworkID}}:{{.IPAddress}} {{end}}' "$cid")
        # Map network IDs to network names for this container
        map=$(docker inspect -f '{{range $k,$v := .NetworkSettings.Networks}}{{$k}}:{{$v.NetworkID}} {{end}}' "$cid")
        # Build readable network->IP pairs
        readable=$(echo "$raw $map" | awk '
            {
                container=$1;
                for(i=2;i<=NF;i++) raw[i-1]=$i;
                raw_cnt=NF;
                split_point=raw_cnt;
                for(i=1;i<=raw_cnt;i++) {
                    if(index(raw[i],":") && length(raw[i])>30) { split_point=i-1; break }
                }
                for(i=split_point+1;i<=raw_cnt;i++) {
                    split(split[i],":"); id_to_name[split[i][2]]=split[i][1];
                }
                out="";
                for(i=1;i<=split_point;i++) {
                    split(raw[i],":"); net_id=split[2]; ip=split[3]; net_name=id_to_name[net_id]; if(net_name=="") net_name="unknown";
                    out = out (out==""?"":", ") net_name " → " ip;
                }
                printf "| %s | %s | %s | %s |\n", "'$project_name'", $2, substr(container,2), out;
            }
        ')
        echo "$readable"
    done
}

# Print markdown header
printf "| Project | Service | Container | Networks (IP) |\n"
printf "|---------|---------|-----------|----------------|\n"

# Student labs
collect_info "./labs/docker-compose.yml" "student‑labs"
# Black‑Hat‑Bash labs (external path)
BHBDIR="/home/dude/Work/WV_Cyber_Cup_2026/Black-Hat-Bash/lab"
collect_info "$BHBDIR/docker-compose.yml" "Black‑Hat‑Bash"
