## COMEM : force the use of swap by COnstraining MEMory.

- **COMEM** is a **bash script** designed to <u>create situations to force a swap.</u>
- It is based on **cgroup v2** and requires **root** privileges to use.
- By default, the output of the command's execution is stored in result.txt.
- It also measures the pswpin and pswpout values, which measure swap usage, as post-run-to-pre-run values, and add them to the end of output.
- Measure the overall execution time in ms and add it to the end of output.
- The -t option allows the command to be executed n times, and appends the average, minimum, and maximum values of execution time, pswpin, and pswpout to the end of output when enabled.
```
[usage] ./comem.sh
  -m "Memory constraint, e.g. 2G"
  -r "Command to excute, e.g. 7zr b"
  [-o "Output destination, default: result.txt"]
  [-t "Execution repeat times, default: 1"]
```
### Sturct figure
![Image](https://github.com/user-attachments/assets/3c298664-7f0e-40c3-9862-2222fe02b8fd)
### Running example (7-zip Benchmark)

```
root@cslow1:~/comem# ./comem.sh -m 2G -r "7zr b -md25 -mmt30" -t 2
running pre-task
pre-task done, running job
job done, running post-task
all task done
root@cslow1:~/comem# cat result.txt 


7-Zip (a) [64] 16.02 : Copyright (c) 1999-2016 Igor Pavlov : 2016-05-21
p7zip Version 16.02 (locale=C.UTF-8,Utf16=on,HugeFiles=on,64 bits,32 CPUs AMD Ryzen 9 5950X 16-Core Processor             (A20F12),ASM,AES-NI)

AMD Ryzen 9 5950X 16-Core Processor             (A20F12)
CPU Freq: - - - - - - - - -

RAM size:   64242 MB,  # CPU hardware threads:  32
RAM usage:   6618 MB,  # Benchmark threads:     30

                       Compressing  |                  Decompressing
Dict     Speed Usage    R/U Rating  |      Speed Usage    R/U Rating
         KiB/s     %   MIPS   MIPS  |      KiB/s     %   MIPS   MIPS

22:     122995  3011   3974 119650  |    1568757  2939   4552 133777
23:     106917  2834   3844 108936  |    1531238  2924   4531 132500
24:      51427  1495   3698  55295  |    1484328  2899   4494 130281
25:      29824  1031   3302  34052  |    1444399  2890   4448 128541
----------------------------------  | ------------------------------
Avr:            2093   3704  79483  |             2913   4506 131275
Tot:            2503   4105 105379
pswpin: 2203709, pswpout: 2279826
excution_time(ms): 41725


7-Zip (a) [64] 16.02 : Copyright (c) 1999-2016 Igor Pavlov : 2016-05-21
p7zip Version 16.02 (locale=C.UTF-8,Utf16=on,HugeFiles=on,64 bits,32 CPUs AMD Ryzen 9 5950X 16-Core Processor             (A20F12),ASM,AES-NI)

AMD Ryzen 9 5950X 16-Core Processor             (A20F12)
CPU Freq: - - - - - - - - -

RAM size:   64242 MB,  # CPU hardware threads:  32
RAM usage:   6618 MB,  # Benchmark threads:     30

                       Compressing  |                  Decompressing
Dict     Speed Usage    R/U Rating  |      Speed Usage    R/U Rating
         KiB/s     %   MIPS   MIPS  |      KiB/s     %   MIPS   MIPS

22:     122048  3005   3951 118729  |    1539812  2924   4491 131309
23:     106492  2825   3841 108503  |    1512548  2920   4483 130883
24:      49658  1587   3364  53393  |    1475457  2899   4467 129502
25:      29596   994   3398  33792  |    1436086  2882   4434 127801
----------------------------------  | ------------------------------
Avr:            2103   3638  78604  |             2906   4469 129874
Tot:            2505   4054 104239
pswpin: 2269074, pswpout: 2320545
excution_time(ms): 42191

Average pswpin: 2236391, Average pswpout: 2300185
Min pswpin: 2203709, Max pswpin: 2269074
Min pswpout: 2279826, Max pswpout: 2320545
Average execution time: 41958
Min execution time: 41725, Max execution time: 42191
```
