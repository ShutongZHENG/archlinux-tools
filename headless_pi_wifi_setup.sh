#!/bin/bash
set -e

# 检查参数数量是否正确
if [[ $# -ne 3 ]]; then
    echo "Usage: $0 </dev/disk> <ssid> <passphase>"
    exit 1
fi

DISK="$1"
SSID="$2"
PASS="$3"

# 检查是否为块设备
if [[ ! -b "${DISK}" ]]; then
    echo "Not a block device: ${DISK}"
    exit 1
fi

# 检查是否以 root 身份运行
if [[ "${USER}" != "root" ]]; then
    echo "Must run as root."
    exit 1
fi

# 创建 network 配置
cat << EOF > root/etc/systemd/network/wlan0.network
[Match]
Name=wlan0

[Network]
DHCP=yes
EOF

# 生成 wpa_supplicant 配置
wpa_passphrase "${SSID}" "${PASS}" > root/etc/wpa_supplicant/wpa_supplicant-wlan0.conf

# 创建符号链接以启用 wpa_supplicant 服务
ln -s \
/usr/lib/systemd/system/wpa_supplicant@.service \
root/etc/systemd/system/multi-user.target.wants/wpa_supplicant@wlan0.service

