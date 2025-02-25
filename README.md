## COMEM : force the use of swap by COnstraining MEMory.
- **COMEM**은 <u>swap을 강제하기 위해 제작된 bash script</u> 입니다.
- **cgroup v2**를 기반으로 만들어져 있으며, 사용시 **sudo** 권한이 필요합니다.
<<<<<<< Updated upstream
```
[usage] ./comem.sh -m "memory" -r "something you want to run" [-o] "output, default: result.txt"
```
- Example

```
./comem.sh -m "2G" -r "7zr b -mmt32 -md26"
```
=======
- default 값으로 명령어의 실행 output은 result.txt에 저장됩니다.
- 또한 swap 사용량을 측정하는 pswpin, pswpout 값은 실행후-실행전 값으로 측정되어 result.txt의 끝에 추가됩니다.
```
[usage] ./comem.sh -m "memory" -r "something you want to run" [-o] "output, default: result.txt"
```
### Running example (7-zip Benchmark)

```
cslab@cslow1:~/comem$ sudo ./comem.sh -m 2G -r "7zr b -md26"
running pre-task
pre-task done, running job
job done, running post-task
userdel: tmp_auto mail spool (/var/mail/tmp_auto) not found
all task done
cslab@cslow1:~/comem$ cat result.txt 


7-Zip (r) 23.01 (x64) : Igor Pavlov : Public domain : 2023-06-20
 64-bit locale=C.UTF-8 Threads:32 OPEN_MAX:1024

 d26
Compiler: 13.2.0 GCC 13.2.0: SSE2
Linux : 6.13.1-DAMG : #1 SMP PREEMPT_DYNAMIC Mon Feb 17 05:29:45 UTC 2025 : x86_64
PageSize:4KB THP:madvise hwcap:2 hwcap2:2
AMD Ryzen 9 5950X 16-Core Processor (A20F12) 

1T CPU Freq (MHz):  4790  4811  4806  4810  4818  4808  4841
16T CPU Freq (MHz): 1540% 4491   1598% 4608  

RAM size:   64236 MB,  # CPU hardware threads:  32
RAM usage:  13039 MB,  # Benchmark threads:     32

                       Compressing  |                  Decompressing
Dict     Speed Usage    R/U Rating  |      Speed Usage    R/U Rating
         KiB/s     %   MIPS   MIPS  |      KiB/s     %   MIPS   MIPS

22:     136138  2950   4489 132435  |    1749560  3184   4686 149166
23:     117561  2813   4258 119781  |    1716258  3183   4665 148480
24:      57488  1357   4554  61811  |    1611239  3041   4650 141381
25:      44786  1058   4834  51135  |    1517639  2942   4589 135025
26:      16918   557   3702  20617  |     808345  1850   3939  72894
----------------------------------  | ------------------------------
Avr:     74578  1747   4368  77156  |    1480608  2840   4506 129389
Tot:            2293   4437 103273
pswpin: 8034795, pswpout: 7336958
```
