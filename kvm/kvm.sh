#!/bin/bash

function init() {
    apt install -y qemu-kvm \
                    libvirt-daemon-system \
                    libvirt-clients \
                    bridge-utils \
                    virtinst \
                    libosinfo-bin \
                    netplan.io
}

function finish() {
    apt remove -y   qemu-kvm \
                    libvirt-daemon-system \
                    libvirt-clients \
                    bridge-utils \
                    virtinst \
                    libosinfo-bin \
                    netplan.io
}

function apply_bridge_config() {
    cp ./00-installer-config.yaml /etc/netplan/00-installer-config.yaml
    netplan apply
}

function run () {
    virt-install \
    --name rhel8 \
    --description "RHEL 8.4" \
    --ram 2048 \
    --disk path=/var/lib/libvirt/images/rhel8.img,size=20 \
    --vcpus 2 \
    --os-variant  rhel8.4 \
    --network bridge=br0 \
    --graphics vnc,listen=0.0.0.0,password=password,keymap=ja \
    --video virtio \
    --cdrom /tmp/rhel-8.4-x86_64-boot.iso
}

if [ "$1" == "init" ]; then
    init
elif [ "$1" == "finish" ]; then
    finish
elif [ "$1" == "apply" ]; then
    apply_bridge_config
elif [ "$1" == "run" ]; then
    run
else
    echo "Usage: $0 [init|finish|apply|run]"
    exit 1
fi

exit 0
