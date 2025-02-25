#!/bin/bash

# 用户输入新磁盘/分区路径
read -p "请输入要添加的磁盘或分区路径 (例如 /dev/sdb): " NEW_DISK

echo "当前可选的卷组列表:"
vgs
read -p "请输入要扩展的卷组名称 (例如 vg_name): " VG_NAME

echo "卷组 $VG_NAME 中现有的逻辑卷:"
lvs $VG_NAME
read -p "请输入要扩展的逻辑卷名称 (例如 lv_name): " LV_NAME

# 检查用户输入是否为空
if [[ -z "$NEW_DISK" || -z "$VG_NAME" || -z "$LV_NAME" ]]; then
    echo "错误: 请输入有效的磁盘路径、卷组名称和逻辑卷名称。"
    exit 1
fi

# 确保指定磁盘存在
echo "正在检查磁盘 $NEW_DISK 是否可用..."
if ! lsblk | grep -q "$(basename $NEW_DISK)"; then
    echo "错误: 未找到磁盘 $NEW_DISK，请确认磁盘路径是否正确。"
    exit 1
fi

# 创建物理卷
pvcreate "$NEW_DISK"
if [[ $? -ne 0 ]]; then
    echo "错误: 物理卷创建失败，请检查磁盘状态。"
    exit 1
fi

# 扩展卷组
vgextend "$VG_NAME" "$NEW_DISK"
if [[ $? -ne 0 ]]; then
    echo "错误: 卷组扩展失败，请确认卷组名称正确。"
    exit 1
fi

# 扩展逻辑卷
lvextend -l +100%FREE "/dev/$VG_NAME/$LV_NAME"
if [[ $? -ne 0 ]]; then
    echo "错误: 逻辑卷扩展失败，请检查输入参数。"
    exit 1
fi

# 自动调整文件系统大小
FS_TYPE=$(blkid -o value -s TYPE "/dev/$VG_NAME/$LV_NAME")
echo "检测到逻辑卷文件系统类型: $FS_TYPE"
if [[ "$FS_TYPE" == "xfs" ]]; then
    xfs_growfs "/dev/$VG_NAME/$LV_NAME"
elif [[ "$FS_TYPE" == "ext4" ]]; then
    resize2fs "/dev/$VG_NAME/$LV_NAME"
else
    echo "错误: 该文件系统类型 ($FS_TYPE) 不支持自动调整，请手动执行调整命令。"
    exit 1
fi

echo "LVM 扩容成功！逻辑卷 $LV_NAME 已成功扩容。"
