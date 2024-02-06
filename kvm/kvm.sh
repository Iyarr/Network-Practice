

init() {
    apt install -y qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils virtinst libosinfo-bin
}

finish() {
    apt remove -y   qemu-kvm \
                    libvirt-daemon-system \
                    libvirt-clients \
                    bridge-utils \
                    virtinst \
                    libosinfo-bin
}

apply_bridge_config() {
    cp ./00-installer-config.yaml /etc/netplan/00-installer-config.yaml
    netplan apply
}

if [ "$1" == "init" ]; then
    init
elif [ "$1" == "finish" ]; then
    finish
elif [ "$1" == "apply" ]; then
    apply_bridge_config
fi

exit 0
