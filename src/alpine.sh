#!/bin/bash
set -e
DESTDIR=$(realpath ~/.alpine/)
REPO=http://dl-cdn.alpinelinux.org/alpine/edge
if [[ ! -f ${DESTDIR}/etc/os-release ]] ; then
    mkdir ${DESTDIR}/{dev,sys,proc} -p
    cd ${DESTDIR}
    tar --exclude dev --exclude sys --exclude proc -xf /app/alpine.tar.gz
    chown ${USER} -R chroot
    chmod 755 -R chroot
    mv chroot/* ${DESTDIR}
    rm -rf chroot
    cat /etc/resolv.conf > ${DESTDIR}/etc/resolv.conf
    echo "alpine" > ${DESTDIR}/etc/hostname
    install ${DESTDIR}/usr/bin/proot.static ${DESTDIR}/proot
fi
flatpak-spawn --host xhost + local: &>/dev/null || true
bash
exec flatpak-spawn --host --clear-env bwrap --bind ${DESTDIR}/ / \
        --bind / /host \
        --proc /proc \
        --bind /sys /sys \
        --dev /dev \
        --bind /tmp /tmp \
        --share-net \
        --die-with-parent \
        --hostname alpine \
        --dir /run/user/ \
        --unshare-uts \
        --dev-bind /dev/dri /dev/dri \
        /proot -w / -0 -r / /bin/sh -c "
            export PULSE_SERVER=127.0.0.1
            export USER=root
            export DISPLAY=:0
            . /etc/profile
            exec /bin/bash
        "
