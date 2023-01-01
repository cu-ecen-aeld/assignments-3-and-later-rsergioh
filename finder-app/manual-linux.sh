#!/bin/bash
# Script outline to install and build kernel.
# Author: Siddhant Jajoo.

set -e
set -u

OUTDIR=/tmp/aeld
KERNEL_REPO=git://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git
KERNEL_VERSION=v5.1.10
BUSYBOX_VERSION=1_33_1
FINDER_APP_DIR=$(realpath $(dirname $0))
ARCH=arm64
CROSS_COMPILE=aarch64-none-linux-gnu-

if [ $# -lt 1 ]
then
	echo "Using default directory ${OUTDIR} for output"
else
	OUTDIR=$1
	echo "Using passed directory ${OUTDIR} for output"
fi

mkdir -p ${OUTDIR}

cd "$OUTDIR"
if [ ! -d "${OUTDIR}/linux-stable" ]; then
    #Clone only if the repository does not exist.
	echo "CLONING GIT LINUX STABLE VERSION ${KERNEL_VERSION} IN ${OUTDIR}"
	git clone ${KERNEL_REPO} --depth 1 --single-branch --branch ${KERNEL_VERSION}
fi
if [ ! -e ${OUTDIR}/linux-stable/arch/${ARCH}/boot/Image ]; then
    cd linux-stable
    echo "Checking out version ${KERNEL_VERSION}"
    git checkout ${KERNEL_VERSION}

    # TODO: Add your kernel build steps here
    #Clean previous build
    echo
    echo
    echo "Cleaning previous build"
    make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} mrproper
    # Build defconfig
    echo
    echo
    echo "Building defconfig"
    echo "make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} O=${OUTDIR} defconfig"
    make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} defconfig
    # Build vmlinux target
    echo
    echo
    echo "Building vmlinux target"
    echo "make -j4 ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} O=${OUTDIR} all"
    make -j4 ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} all
    # Build modules
    echo
    echo
    echo "Building modules"
    echo "make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} O=${OUTDIR} modules"
    make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} modules
    # Build devicetree
    echo
    echo
    echo "Building devicetree"
    echo "make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} O=${OUTDIR} dtbs"
    make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} dtbs
fi

echo
echo
echo "Adding the Image in outdir"
cd "$OUTDIR"
cp linux-stable/arch/arm64/boot/Image $OUTDIR
echo
echo
echo "Creating the staging directory for the root filesystem"
cd "$OUTDIR"
if [ -d "${OUTDIR}/rootfs" ]
then
	echo "Deleting rootfs directory at ${OUTDIR}/rootfs and starting over"
    sudo rm  -rf ${OUTDIR}/rootfs
fi

# TODO: Create necessary base directories
echo
echo
echo "Create base directories"
mkdir "${OUTDIR}/rootfs"
cd "${OUTDIR}/rootfs"
mkdir bin dev etc home lib lib64 proc sbin sys tmp usr var
mkdir usr/bin usr/lib usr/sbin
mkdir -p var/log

cd "$OUTDIR"
if [ ! -d "${OUTDIR}/busybox" ]
then
	
	echo
	echo
	echo "Cloning busybox"
	git clone git://busybox.net/busybox.git
    cd busybox
    git checkout ${BUSYBOX_VERSION}
    # TODO:  Configure busybox
    make distclean
	make defconfig
else
    cd busybox
fi

# TODO: Make and install busybox
echo
echo
echo "make CONFIG_PREFIX=${OUTDIR}/rootfs ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} install"
make CONFIG_PREFIX=${OUTDIR}/rootfs ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} install

echo
echo
echo "Library dependencies"
${CROSS_COMPILE}readelf -a ${OUTDIR}/rootfs/bin/busybox | grep "program interpreter"
${CROSS_COMPILE}readelf -a ${OUTDIR}/rootfs/bin/busybox | grep "Shared library"

# TODO: Add library dependencies to rootfs
echo
echo
echo "Adding library dependencies to rootfs"
SYSROOT=$(${CROSS_COMPILE}gcc -print-sysroot)
cd "${OUTDIR}/rootfs"
cp -av ${SYSROOT}/lib/ld-linux-aarch64.so.1 lib
cp -av ${SYSROOT}/lib64/ld-2.31.so lib64
cp -av ${SYSROOT}/lib64/libm.so.6 lib64
cp -av ${SYSROOT}/lib64/libm-2.31.so lib64
cp -av ${SYSROOT}/lib64/libresolv.so.2 lib64
cp -av ${SYSROOT}/lib64/libresolv-2.31.so lib64
cp -av ${SYSROOT}/lib64/libc.so.6 lib64
cp -av ${SYSROOT}/lib64/libc-2.31.so lib64
# TODO: Make device nodes
echo
echo
echo "Creating device nodes"
sudo mknod -m 666 dev/console c 5 1
echo "mknod -m 666 dev/console c 5 1"
sudo mknod -m 666 dev/null c 1 3
echo "mknod -m 666 dev/null c 1 3"
# TODO: Clean and build the writer utility
echo
echo
echo "Building Writer Utility"
cd $FINDER_APP_DIR
make clean
make CROSS_COMPILE=${CROSS_COMPILE}
# TODO: Copy the finder related scripts and executables to the /home directory
# on the target rootfs
echo
echo
echo "Copying writer related files."
mkdir -p ${OUTDIR}/rootfs/home/conf
cp -v "finder.sh" "${OUTDIR}/rootfs/home"
cp -v "conf/username.txt" "${OUTDIR}/rootfs/home/conf"
cp -v "conf/assignment.txt" "${OUTDIR}/rootfs/home/conf"
cp -v "finder-test.sh" "${OUTDIR}/rootfs/home"
cp -v "writer" "${OUTDIR}/rootfs/home"
cp -v "autorun-qemu.sh" "${OUTDIR}/rootfs/home"
# TODO: Chown the root directory
cd "${OUTDIR}/rootfs"
sudo chown -R root:root *
# TODO: Create initramfs.cpio.gz
echo
echo
echo "Creating initramfs"
find . | cpio -o -H newc | gzip > ../initramfs.cpio.gz
