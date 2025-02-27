## COMEM : force the use of swap by COnstraining MEMory.
- **COMEM**은 <u>swap을 강제하는 상황을 만들기 위해 제작된 bash script</u> 입니다.
- **cgroup v2**를 기반으로 만들어져 있으며, 사용시 **sudo** 권한이 필요합니다.
- default 값으로 명령어의 실행 output은 result.txt에 저장됩니다.
- 또한 swap 사용량을 측정하는 pswpin, pswpout 값을 실행후-실행전 값으로 측정하어 output의 끝에 추가합니다.
- 전체적인 실행시간을 ms단위로 측정하여 output의 끝에 추가합니다.
- t 옵션을 통해 해당 명령어를 n번 반복실행할 수 있으며, 해당 옵션을 활성화할시 실행시간, pswpin, pswpout의 평균, 최소, 최대값을 output의 끝에 추가합니다.
```
[usage] ./comem.sh
  -m "Memory constraint, e.g. 2G"
  -r "Command to excute, e.g. 7zr b"
  [-o "Output destination, default: result.txt"]
  [-t "Execution repeat times, default: 1"]
```
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
