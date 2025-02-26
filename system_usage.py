import os
from datetime import datetime

import psutil

# 巡检时间
inspection_time = datetime.now().strftime("%Y-%m-%d_%H:%M:%S")
directory = "/tmp"
filename = f"system-usage-{inspection_time}.txt"
filepath = os.path.join(directory, filename)

with open(filepath, "w") as f:
    f.write(f"巡检时间: {inspection_time}\n")

    # 平均负载
    f.write("======================平均负载======================\n")
    avg_load = str(psutil.getloadavg())
    f.write(f'{"平均负载": <8s}\t{avg_load}\n\n')

    # CPU 使用情况
    f.write("====================CPU 使用情况====================\n")
    cpu_usage = psutil.cpu_percent(interval=5)
    f.write(f'{"CPU使用率": <8s}\t{cpu_usage: >8}%\n\n')

    # 内存使用情况
    f.write("====================内存使用情况====================\n")
    memory_info = psutil.virtual_memory()
    f.write(f'{"总内存": <8s}\t{memory_info.total / (1024 ** 3): >6.2f} GB\n')
    f.write(f'{"已用内存": <8s}\t{memory_info.used / (1024 ** 3): >6.2f} GB\n')
    f.write(f'{"空闲内存": <8s}\t{memory_info.available / (1024 ** 3): >6.2f} GB\n')
    f.write(f'{"内存使用率": <8s}\t{memory_info.percent: >8}%\n\n')

    # 磁盘使用情况
    f.write("=================磁盘根分区使用情况=================\n")
    disk_info = psutil.disk_usage("/")
    f.write(f'{"总空间": <8s}\t{disk_info.total / (1024 ** 3): >6.2f} GB\n')
    f.write(f'{"已用空间": <8s}\t{disk_info.used / (1024 ** 3): >6.2f} GB\n')
    f.write(f'{"空闲空间": <8s}\t{disk_info.free / (1024 ** 3): >6.2f} GB\n')
    f.write(f'{"使用率": <8s}\t{disk_info.percent: >8}%\n\n')

    # 网络 I/O
    f.write("======================网络 I/O======================\n")
    net_io = psutil.net_io_counters()
    f.write(f'{"发送字节数": <8s}\t{net_io.bytes_sent / 1024 / 1024: >6.2f} MB\n')
    f.write(f'{"接收字节数": <8s}\t{net_io.bytes_recv / 1024 / 1024: >6.2f} MB\n')
    f.write(f'{"发送数据包": <8s}\t{net_io.packets_sent: >9}\n')
    f.write(f'{"接收数据包": <8s}\t{net_io.packets_recv: >9}\n\n')

print(f"系统资源巡检报告已保存: {filepath}")
