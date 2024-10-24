import psutil
from datetime import datetime

# 巡检时间
inspection_time = datetime.now().strftime("%Y-%m-%d_%H:%M:%S")
filename = f"system-usage-{inspection_time}.txt"

with open(filename, "w") as f:
    f.write(f"巡检时间: {inspection_time}\n")

    # CPU 使用情况
    f.write("====================CPU 使用情况====================\n")
    cpu_usage = psutil.cpu_percent(interval=1)
    f.write(f'{"CPU使用率":<8s}\t{cpu_usage:>8}%\n')

    # 内存使用情况
    f.write("====================内存使用情况====================\n")
    memory_info = psutil.virtual_memory()
    f.write(f'{"总内存":<8s}\t{memory_info.total / (1024 ** 3):>6.2f} GB\n')
    f.write(f'{"已用内存":<8s}\t{memory_info.used / (1024 ** 3):>6.2f} GB\n')
    f.write(f'{"空闲内存":<8s}\t{memory_info.available / (1024 ** 3):>6.2f} GB\n')
    f.write(f'{"内存使用率":<8s}\t{memory_info.percent:>8}%\n')

    # 磁盘使用情况
    f.write("=================磁盘根分区使用情况=================\n")
    disk_info = psutil.disk_usage("/")
    f.write(f'{"总空间":<8s}\t{disk_info.total / (1024 ** 3):>6.2f} GB\n')
    f.write(f'{"已用空间":<8s}\t{disk_info.used / (1024 ** 3):>6.2f} GB\n')
    f.write(f'{"空闲空间":<8s}\t{disk_info.free / (1024 ** 3):>6.2f} GB\n')
    f.write(f'{"使用率":<8s}\t{disk_info.percent:>8}%\n')

print(f"系统资源使用情况巡检报告已保存到 {filename} 文件。")
