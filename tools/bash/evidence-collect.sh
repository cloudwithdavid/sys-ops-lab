#!/usr/bin/env bash

# evidence-collect.sh
# First-pass Linux networking and service evidence collection utility.
#
# Primarily server-side — collects service status, logs, and listening ports alongside routing and reachability checks. Can also be run client-side for name resolution, routing, and application reachability checks. All output is written to a timestamped file for ticket attachment or escalation reference.
#
# Examples:
#   ./evidence-collect.sh -s cron -e cloudwithdavid.com -i 1.1.1.1
#   ./evidence-collect.sh -s apache2 -e https://cloudwithdavid.com -i 8.8.8.8

set -euo pipefail

header() {
  printf '\n--- %s ---\n' "$1" | tee -a "$output_file"
}

write() {
  printf '%s\n' "$@" | tee -a "$output_file"
}

run_command() {
  "$@" |& tee -a "$output_file"
}

usage() {
  printf 'Usage: %s [-s <service-name>] [-i <target-ip>] [-e <endpoint>]\n\n' "$0"
  printf 'Options:\n'
  printf '  -s  Service name to check with systemctl and journalctl\n'
  printf '  -i  Target IP address to check with ping. Default: 8.8.8.8\n'
  printf '  -e  Endpoint hostname or HTTP/HTTPS URL to check. Default: https://example.com\n'
  printf '  -h  Show this help message\n'
}

normalize_endpoint() {
  local input="$1"
  local host="$input"
  local url="$input"

  host="${host#http://}"
  host="${host#https://}"
  host="${host%%/*}"
  host="${host%%:*}"

  if [[ "$url" != http://* && "$url" != https://* ]]; then
    url="https://$url"
  fi

  target_host="$host"
  target_url="$url"
}

service_name=""
target_ip="8.8.8.8"
target_endpoint="https://example.com"
target_host=""
target_url=""
output_dir="evidence"

while getopts ":s:i:e:h" opt; do
  case "$opt" in
    s)
      service_name="$OPTARG"
      ;;
    i)
      target_ip="$OPTARG"
      ;;
    e)
      target_endpoint="$OPTARG"
      ;;
    h)
      usage
      exit 0
      ;;
    :)
      printf 'Error: option -%s requires a value\n' "$OPTARG"
      usage
      exit 1
      ;;
    \?)
      printf 'Error: -%s is an invalid option\n' "$OPTARG"
      usage
      exit 1
      ;;
  esac
done

normalize_endpoint "$target_endpoint"

current_host="$(hostname)"
current_user="$(whoami)"
timestamp="$(date '+%Y-%m-%d %H:%M:%S')"
file_timestamp="$(date '+%Y%m%d-%H%M%S')"

mkdir -p "$output_dir"

output_file="${output_dir}/${file_timestamp}-${current_host}.txt"

: > "$output_file"

header "Collecting Evidence"
write "Timestamp:   $timestamp"
write "Host:        $current_host"
write "User:        $current_user"

if [[ -n "$service_name" ]]; then
  write "Service:     $service_name"
else
  write "Service:     not provided"
fi

write "Target IP:   $target_ip"
write "Target Host: $target_host"
write "Target URL:  $target_url"

header "Service Status"
if [[ -n "$service_name" ]]; then
  run_command systemctl status "$service_name" --no-pager \
    || write "Result: service status could not be collected"
else
  write "Result: skipped because no service name was provided"
fi

header "Recent Journal Logs"
if [[ -n "$service_name" ]]; then
  run_command journalctl -u "$service_name" -n 25 --no-pager \
    || write "Result: recent journal logs could not be collected"
else
  write "Result: skipped because no service name was provided"
fi

header "Target Name Resolution"
run_command getent hosts "$target_host" \
  || write "Target name resolution check failed; target host could not be resolved"

header "Routing Table"
run_command ip route \
  || write "Routing table information could not be collected"

header "Target IP Reachability"
run_command ping -c 4 "$target_ip" \
  || write "Target IP reachability check failed; target IP did not respond or could not be reached"

header "Listening Ports"
run_command ss -tuln \
  || write "Listening ports information could not be collected"

header "Target URL Reachability"
run_command curl -sSI --max-time 5 "$target_url" \
  || write "Target URL reachability check failed; target URL did not return a reachable HTTP/HTTPS response"

printf 'Evidence saved to: %s\n' "$output_file"