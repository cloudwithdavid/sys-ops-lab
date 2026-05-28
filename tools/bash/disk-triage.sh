#!/usr/bin/env bash

# disk-triage.sh
# First-pass disk usage triage utility.
#
# Checks filesystem usage, flags filesystems above a configurable threshold, shows the largest entries under a target path, and optionally saves output to a timestamped file for ticket attachment or escalation reference.
#
# Examples:
#   ./disk-triage.sh
#   ./disk-triage.sh -p /var
#   ./disk-triage.sh -p /var -t 80 -d 2
#   ./disk-triage.sh -p /var/log -t 85 -o

set -euo pipefail

target_path="/"
threshold="85"
depth="1"
save_output=false
output_dir="evidence"
output_file=""
flagged=""

usage() {
  printf 'Usage: %s [-p <path>] [-t <threshold>] [-d <depth>] [-o] [-h]\n\n' "$0"
  printf 'Options:\n'
  printf '  -p  Path to inspect for largest entries. Default: /\n'
  printf '  -t  Filesystem usage threshold percentage to flag. Default: 85\n'
  printf '  -d  Depth for largest entry breakdown. Default: 1\n'
  printf '  -o  Save output to a timestamped file\n'
  printf '  -h  Show this help message\n'
}

write() {
  if [[ "$save_output" == true ]]; then
    printf '%s\n' "$@" | tee -a "$output_file"
  else
    printf '%s\n' "$@"
  fi
}

header() {
  if [[ "$save_output" == true ]]; then
    printf '\n--- %s ---\n' "$1" | tee -a "$output_file"
  else
    printf '\n--- %s ---\n' "$1"
  fi
}

run_command() {
  if [[ "$save_output" == true ]]; then
    "$@" |& tee -a "$output_file"
  else
    "$@"
  fi
}

while getopts ":p:t:d:sh" opt; do
  case "$opt" in
    p)
      target_path="$OPTARG"
      ;;
    t)
      threshold="$OPTARG"
      ;;
    d)
      depth="$OPTARG"
      ;;
    s)
      save_output=true
      ;;
    h)
      usage
      exit 0
      ;;
    :)
      printf 'Error: -%s requires a value\n' "$OPTARG"
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

if [[ ! -d "$target_path" ]]; then
  printf 'Error: path does not exist or is not a directory: %s\n' "$target_path"
  exit 1
fi

if ! [[ "$threshold" =~ ^[0-9]+$ ]] || [[ "$threshold" -lt 1 || "$threshold" -gt 100 ]]; then
  printf 'Error: threshold must be a number between 1 and 100\n'
  exit 1
fi

if ! [[ "$depth" =~ ^[0-9]+$ ]] || [[ "$depth" -lt 1 ]]; then
  printf 'Error: depth must be a positive number\n'
  exit 1
fi

target_size="$(du -xsh "$target_path" 2>/dev/null | cut -f1 || true)"

if [[ "$save_output" == true ]]; then
  mkdir -p "$output_dir"
  file_timestamp="$(date '+%Y%m%d-%H%M%S')"
  current_host="$(hostname)"
  output_file="${output_dir}/${file_timestamp}-${current_host}-disk-triage.txt"
  : > "$output_file"
fi

header "Disk Triage"
write "Timestamp:  $(date '+%Y-%m-%d %H:%M:%S')"
write "Host:       $(hostname)"
write "Path:       $target_path"
write "Path Size:  ${target_size:-could not determine}"
write "Threshold:  ${threshold}%"
write "Depth:      $depth"

header "Filesystem Usage"
run_command df -h \
  || write "Filesystem usage could not be collected"

header "Filesystems Above Threshold"
while read -r usage mountpoint; do
  usage_number="${usage%\%}"

  if [[ "$usage_number" -ge "$threshold" ]]; then
    flagged+="${usage} ${mountpoint}"$'\n'
  fi
done < <(df -h --output=pcent,target 2>/dev/null | tail -n +2)

if [[ -n "$flagged" ]]; then
  write "$flagged"
else
  write "No filesystems above ${threshold}%"
fi

header "Largest Entries Under $target_path (depth $depth)"
largest_entries="$(
  du -xh --max-depth="$depth" "$target_path" 2>/dev/null \
    | sort -hr \
    | head -n 20 \
    || true
)"

if [[ -n "$largest_entries" ]]; then
  write "$largest_entries"
else
  write "Largest entries could not be collected"
fi

write ""
write "CAUTION: Confirm ownership, retention requirements, and service impact before cleanup."

if [[ "$save_output" == true ]]; then
  printf '\nOutput saved to: %s\n' "$output_file"
fi