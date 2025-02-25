#!/bin/bash


MEMORY=""
COMMAND=""
OUTPUT="result.txt"


while getopts "m:r:" opt; do
  case $opt in
    m) MEMORY=$OPTARG ;;
    r) COMMAND=$OPTARG ;;
    o) OUTPUT=$OPTARG ;;
    *) echo "[usage] ./comem.sh -m \"memory\" -r \"something you want to run\" [-o] \"output, default: result.txt\""; exit 1 ;;
  esac
done

if [[ -z "$MEMORY" || -z "$COMMAND" ]]; then
  echo "[usage] ./comem.sh -m \"memory\" -r \"something you want to run\" [-o] \"output, default: result.txt\""
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
MemoryMax=2G
EOF
sudo systemctl daemon-reload

echo "" > $OUTPUT
pswpin_before=$(grep 'pswpin' /proc/vmstat | awk '{print $2}')
pswpout_before=$(grep 'pswpout' /proc/vmstat | awk '{print $2}')

echo "pre-task done, running job"
# step 1: running job, do user-input job
sudo -u tmp_auto bash -c "$COMMAND" >> $OUTPUT
pswpin_after=$(grep 'pswpin' /proc/vmstat | awk '{print $2}')
pswpout_after=$(grep 'pswpout' /proc/vmstat | awk '{print $2}')
pswpin_diff=$((pswpin_after - pswpin_before))
pswpout_diff=$((pswpout_after - pswpout_before))
echo "pswpin: $pswpin_diff, pswpout: $pswpout_diff" >> $OUTPUT
echo "job done, running post-task"
# step 2: post-task, remove temp user and memory constraint
sudo rm -rf /etc/systemd/system/user-.slice.d
sudo systemctl daemon-reload
sudo userdel -r tmp_auto

echo "all task done"
