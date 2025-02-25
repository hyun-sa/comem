## COMEM : force the use of swap by COnstraining MEMory.
- **COMEM**은 <u>swap을 강제하기 위해 제작된 bash script</u> 입니다.
- **cgroup v2**를 기반으로 만들어져 있으며, 사용시 **sudo** 권한이 필요합니다.
```
[usage] ./comem.sh -m "memory" -r "something you want to run" [-o] "output, default: result.txt"
```
- Example

`./comem.sh -m "2G" -r "7zr b -mmt32 -md26"`
