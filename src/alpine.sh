#!/bin/bash
set -e
DESTDIR=$(realpath ~/.var/app/io.github.paledega.alpine-rootfs/rootfs/)
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
    install ${DESTDIR}/usr/bin/proot.static ~/proot
fi
exec ~/proot -r ${DESTDIR}/ -w / -0 /bin/sh -c "
            export PULSE_SERVER=127.0.0.1
            export USER=root
            export DISPLAY=:0
            . /etc/profile
            exec /bin/ash $@"
