#!/bin/bash


MEMORY=""
COMMAND=""
OUTPUT="result.txt"
TIMES=1

while getopts "m:r:o:t:" opt; do
  case $opt in
    m) MEMORY=$OPTARG ;;
    r) COMMAND=$OPTARG ;;
    o) OUTPUT=$OPTARG ;;
    t) TIMES=$OPTARG ;;
    *) 
      echo "[usage] ./comem.sh"
      echo "  -m \"Memory constraint, e.g. 2G\""
      echo "  -r \"Command to excute, e.g. 7zr b\""
      echo "  [-o \"Output destination, default: result.txt\"]"
      echo "  [-t \"Execution repeat times, default: 1\"]"
      exit 1 
      ;;
  esac
done

if [[ -z "$MEMORY" || -z "$COMMAND" ]]; then
  echo "[usage] ./comem.sh"
  echo "  -m \"Memory constraint, e.g. 2G\""
  echo "  -r \"Command to excute, e.g. 7zr b\""
  echo "  [-o \"Output destination, default: result.txt\"]"
  echo "  [-t \"Execution repeat times, default: 1\"]"
  exit 1 
fi

if ! sudo -n true 2>/dev/null; then
  echo "You need root permission to run this script"
  exit 1
fi

echo "running pre-task"
# step 0: pre-task, create temp user and memory constraint
sudo useradd -m tmp_auto
sudo mkdir -p /etc/systemd/system/user-.slice.d
cat << EOF | sudo tee /etc/systemd/system/user-.slice.d/50-memory.conf > /dev/null
[Slice]
MemoryMax=$MEMORY
EOF
sudo systemctl daemon-reload

echo "" > $OUTPUT
pswpin_before=$(grep 'pswpin' /proc/vmstat | awk '{print $2}')
pswpout_before=$(grep 'pswpout' /proc/vmstat | awk '{print $2}')

echo "pre-task done, running job"
# step 1: running job, do user-input job
start_time=$(date +%s%3N)
sudo -u tmp_auto bash -c "$COMMAND" >> $OUTPUT
end_time=$(date +%s%3N)
execution_time=$((end_time - start_time))

pswpin_after=$(grep 'pswpin' /proc/vmstat | awk '{print $2}')
pswpout_after=$(grep 'pswpout' /proc/vmstat | awk '{print $2}')
pswpin_diff=$((pswpin_after - pswpin_before))
pswpout_diff=$((pswpout_after - pswpout_before))
echo "pswpin: $pswpin_diff, pswpout: $pswpout_diff" >> $OUTPUT
echo "excution_time(ms): $execution_time" >> $OUTPUT
echo "" >> $OUTPUT

# step 1-1: if times > 1, init
if [[ $TIMES -gt 1 ]]; then
  min_pswpin=$pswpin_diff
  max_pswpin=$pswpin_diff
  min_pswpout=$pswpout_diff
  max_pswpout=$pswpout_diff
  min_execution_time=$execution_time
  max_execution_time=$execution_time
  total_pswpin=$pswpin_diff
  total_pswpout=$pswpout_diff
  total_execution_time=$execution_time
  pswpin_before=$pswpin_after
  pswpout_before=$pswpout_after
fi

sudo swapoff -a
sudo swapon -a

# step 1-2: if times > 1, repeat
for ((i=1; i<TIMES; i++)); do
  start_time=$(date +%s%3N)
  sudo -u tmp_auto bash -c "$COMMAND" >> $OUTPUT
  end_time=$(date +%s%3N)
  execution_time=$((end_time - start_time))
  
  pswpin_after=$(grep 'pswpin' /proc/vmstat | awk '{print $2}')
  pswpout_after=$(grep 'pswpout' /proc/vmstat | awk '{print $2}')
  pswpin_diff=$((pswpin_after - pswpin_before))
  pswpout_diff=$((pswpout_after - pswpout_before))
  echo "pswpin: $pswpin_diff, pswpout: $pswpout_diff" >> $OUTPUT
  echo "excution_time(ms): $execution_time" >> $OUTPUT
  echo "" >> $OUTPUT
  
  total_pswpin=$((total_pswpin + pswpin_diff))
  total_pswpout=$((total_pswpout + pswpout_diff))
  total_execution_time=$((total_execution_time + execution_time)) 
  if (( pswpin_diff < min_pswpin )); then
    min_pswpin=$pswpin_diff
  fi
  if (( pswpin_diff > max_pswpin )); then
    max_pswpin=$pswpin_diff
  fi
  if (( pswpout_diff < min_pswpout )); then
    min_pswpout=$pswpout_diff
  fi
  if (( pswpout_diff > max_pswpout )); then
    max_pswpout=$pswpout_diff
  fi
  if (( execution_time > max_execution_time ));then
    max_execution_time=$execution_time
  fi
  if (( execution_time < min_execution_time ));then
    min_execution_time=$execution_time
  fi

  pswpin_before=$pswpin_after
  pswpout_before=$pswpout_after
  sudo swapoff -a
  sudo swapon -a
done

if [[ $TIMES -gt 1 ]]; then
  avg_pswpin=$((total_pswpin / TIMES))
  avg_pswpout=$((total_pswpout / TIMES))
  avg_execution_time=$((total_execution_time / TIMES))
  echo "Average pswpin: $avg_pswpin, Average pswpout: $avg_pswpout" >> $OUTPUT
  echo "Min pswpin: $min_pswpin, Max pswpin: $max_pswpin" >> $OUTPUT
  echo "Min pswpout: $min_pswpout, Max pswpout: $max_pswpout" >> $OUTPUT
  echo "Average execution time: $avg_execution_time" >> $OUTPUT
  echo "Min execution time: $min_execution_time, Max execution time: $max_execution_time" >> $OUTPUT
fi

echo "job done, running post-task"
# step 2: post-task, remove temp user and memory constraint
sudo rm -rf /etc/systemd/system/user-.slice.d
sudo systemctl daemon-reload
sudo userdel -r tmp_auto 2>/dev/null
echo "all task done"
