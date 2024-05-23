# 3dv-group-tools
Tool scripts for 3DV group daily research

### Slurm commands
```shell
# 这将显示所有使用2个GPU的任务，但不包括由user1提交的任务、任务ID为12345的任务，以及所有类型为spot的任务。
sh squeue_gpu_num.sh -n 2 -u user1 -j 12345 -s

# 这将显示所有使用2个GPU的任务，并取消除了由user1提交的、任务ID为12345的以及所有类型为spot的任务外的所有任务。
sh squeue_gpu_num.sh -n 2 -u user1 -j 12345 -s -c
```