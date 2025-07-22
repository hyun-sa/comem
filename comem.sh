#!/bin/bash

MEMORY=""
COMMAND=""
OUTPUT="result.txt"
TIMES=1
TIERED_MODE=false

new_args=()
while [[ $# -gt 0 ]]; do
  case "$1" in
    --tiered)
      TIERED_MODE=true
      shift
      ;;
    *)
      new_args+=("$1")
      shift
      ;;
  esac
done

set -- "${new_args[@]}"

while getopts "m:r:o:t:" opt; do
  case $opt in
    m) MEMORY=$OPTARG ;;
    r) COMMAND=$OPTARG ;;
    o) OUTPUT=$OPTARG ;;
    t) TIMES=$OPTARG ;;
    *)
      echo "Usage: sudo $0 -m <memory> -r <command> [-o <output_file>] [-t <repetitions>]"
      echo "  -m: Memory limit (e.g., 2G, 512M)"
      echo "  -r: Command to execute (wrap in quotes, e.g., \"7zr b\")"
      echo "  -o: Output file for results (default: result.txt)"
      echo "  -t: Number of repetitions (default: 1)"
      echo "  --tiered: Enable collection of tiered memory stats (pgpromote/pgdemote)."
      exit 1
      ;;
  esac
done

if [[ -z "$MEMORY" || -z "$COMMAND" ]]; then
  echo "Error: -m (memory) and -r (command) options are mandatory."
  echo "Usage: sudo $0 -m <memory> -r <command> [-o <output_file>] [-t <repetitions>] [--tiered]"
  exit 1
fi

if [[ $EUID -ne 0 ]]; then
   echo "Error: This script must be run as root. (e.g., sudo $0 ...)"
   exit 1
fi

CGROUP_NAME="comem-group-$(date +%s)-${RANDOM}"
CGROUP_PATH="/sys/fs/cgroup/${CGROUP_NAME}"

cleanup() {
  if [ "$cleanup_running" = "true" ]; then
    return
  fi
  cleanup_running=true

  echo "[INFO] Task finished. Cleaning up cgroup..."
  if [ -d "$CGROUP_PATH" ]; then
    if [ -f "${CGROUP_PATH}/cgroup.kill" ]; then
      echo "[INFO] Terminating all processes in cgroup '$CGROUP_PATH' using cgroup.kill."
      echo 1 > "${CGROUP_PATH}/cgroup.kill" 2>/dev/null
      sleep 0.2
    fi

    if rmdir "$CGROUP_PATH"; then
      echo "[INFO] Cgroup '$CGROUP_PATH' successfully deleted."
    else
      sleep 0.5
      if rmdir "$CGROUP_PATH" 2>/dev/null; then
        echo "[INFO] Cgroup '$CGROUP_PATH' successfully deleted on second attempt."
      else
        echo "[WARN] Failed to delete cgroup '$CGROUP_PATH'."
      fi
    fi
  fi
}

trap cleanup EXIT INT TERM

echo "[INFO] Creating cgroup '$CGROUP_PATH'."
mkdir -p "$CGROUP_PATH"
if [ $? -ne 0 ]; then
    echo "[ERROR] Failed to create cgroup. Check if the system uses cgroup v2."
    exit 1
fi

echo $$ > "${CGROUP_PATH}/cgroup.procs"
if [ $? -ne 0 ]; then
    echo "[ERROR] Failed to move script PID $$ into cgroup. Aborting."
    exit 1
fi
echo "[INFO] Script (PID: $$) and its future children are now in the cgroup."


if ! grep -q "memory" "${CGROUP_PATH}/../cgroup.controllers"; then
    echo "[ERROR] The 'memory' controller is not available for this cgroup."
    exit 1
fi

echo "[INFO] Setting memory limit to '$MEMORY' (memory.high)."
echo "$MEMORY" > "${CGROUP_PATH}/memory.high"
echo 0 > "${CGROUP_PATH}/memory.swap.max"
if [ $? -ne 0 ]; then
    echo "[ERROR] Failed to set memory limit. Check if the memory.high controller is enabled."
    exit 1
fi

echo "[INFO] Starting job. Results will be saved to '$OUTPUT'."
echo "" > "$OUTPUT"

total_execution_time=0
min_execution_time=-1
max_execution_time=-1

for ((i=0; i<TIMES; i++)); do
  echo "[INFO] Running iteration $((i+1))/$TIMES..."

  start_time=$(date +%s%3N)

  ( eval "$COMMAND" ) >> "$OUTPUT" 2>&1

  end_time=$(date +%s%3N)
  execution_time=$((end_time - start_time))

  echo "execution_time(ms): $execution_time" >> "$OUTPUT"
  echo "" >> "$OUTPUT"

  total_execution_time=$((total_execution_time + execution_time))
  if (( min_execution_time == -1 || execution_time < min_execution_time )); then
    min_execution_time=$execution_time
  fi
  if (( execution_time > max_execution_time )); then
    max_execution_time=$execution_time
  fi
done

if [[ $TIMES -gt 1 ]]; then
  avg_execution_time=$((total_execution_time / TIMES))
  summary="
-------------------------------------
           Execution Summary
-------------------------------------
- Average execution time: ${avg_execution_time} ms
- Minimum execution time: ${min_execution_time} ms
- Maximum execution time: ${max_execution_time} ms
-------------------------------------
"
  echo "$summary" | tee -a "$OUTPUT"
fi

if [ "$TIERED_MODE" = "true" ]; then
  TIERED_STAT=$(grep -E 'pgpromote|pgdemote' /proc/vmstat)
  echo "$TIERED_STAT" | tee -a "$OUTPUT"
fi

echo "[INFO] All tasks completed."

exit 0

