## COMEM : force the use of memory reclaim by COnstraining MEMory.

- **COMEM** is a **bash script** designed to <u>create situations to force swap or demotion.</u>
- It is based on **cgroup v2** and requires **root** privileges to use.
- By default, the output of the command's execution is stored in result.txt.
- Measure the overall execution time in ms and add it to the end of output.
- The -t option allows the command to be executed n times, and appends the average, minimum, and maximum values of execution time to the end of output when enabled.
```
Usage: sudo ./comem.sh -m <memory> -r <command> [-o <output_file>] [-t <repetitions>] [--tiered]
  -m: Memory limit (e.g., 2G, 512M)
  -r: Command to execute (wrap in quotes, e.g., "7zr b")
  -o: Output file for results (default: result.txt)
  -t: Number of repetitions (default: 1)
  --tiered: Enable collection of tiered memory stats (pgpromote/pgdemote) (default: false).
```
### Running example (7-zip Benchmark)

```
~/comem$ sudo ./comem.sh -m 8g -r "7zr b -md25" --tiered
[INFO] Creating cgroup '/sys/fs/cgroup/comem-group-1753150778-18510'.
[INFO] Script (PID: 3647) and its future children are now in the cgroup.
[INFO] Setting memory limit to '8g' (memory.high).
[INFO] Starting job. Results will be saved to 'result.txt'.
[INFO] Running iteration 1/1...
pgpromote_success 9890827
pgpromote_candidate 0
pgdemote_kswapd 0
pgdemote_direct 20993103
pgdemote_khugepaged 0
pgdemote_proactive 0
[INFO] All tasks completed.
[INFO] Task finished. Cleaning up cgroup...
[INFO] Terminating all processes in cgroup '/sys/fs/cgroup/comem-group-1753150778-18510' using cgroup.kill.
```
