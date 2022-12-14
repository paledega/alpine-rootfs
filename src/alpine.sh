#!/bin/bash
set -e
mkdir -p ~/.var/app/io.github.paledega.alpine-rootfs/rootfs/
DESTDIR=$(realpath ~/.var/app/io.github.paledega.alpine-rootfs/rootfs/)
REPO=http://dl-cdn.alpinelinux.org/alpine/edge
if [[ ! -f ${DESTDIR}/etc/os-release || ! -f ${DESTDIR}/proot ]] ; then
    rm -rf  ${DESTDIR} || true
    mkdir -p ${DESTDIR}/{dev,sys,proc}
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
if [[ $1 == "" ]]; then
    prg="/bin/ash"
fi
exec env -i ${DESTDIR}/proot -r ${DESTDIR}/ -w / -0 -b /dev -b /sys -b /proc -b /run /bin/sh -c "
            export PULSE_SERVER=127.0.0.1
            export USER=root
            . /etc/profile
            exec $prg $@"
