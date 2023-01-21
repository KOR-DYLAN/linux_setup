#!/bin/bash

ARM_URL_PREFIX=https://developer.arm.com/-/media/Files/downloads
ARM_PROFILE=gnu-a
ARM_VERSION=10.3-2021.07

ARM_TARGETS=$ARM_TARGETS:"arm-none-eabi"
ARM_TARGETS=$ARM_TARGETS:"arm-none-linux-gnueabihf"
ARM_TARGETS=$ARM_TARGETS:"aarch64-none-elf"
ARM_TARGETS=$ARM_TARGETS:"aarch64-none-linux-gnu"

TOOLCAHIN_BASE=/opt

URL_FILE=urls.txt

rm -f $URL_FILE
for i in $(echo $ARM_TARGETS | tr ":" " ")
do
    if [ ! -e gcc-arm-${ARM_VERSION}-${HOSTTYPE}-${i}.tar.xz ]; then
        echo "${ARM_URL_PREFIX}/${ARM_PROFILE}/${ARM_VERSION}/binrel/gcc-arm-${ARM_VERSION}-${HOSTTYPE}-${i}.tar.xz ${URLS}" >> $URL_FILE
    fi

done

if which aria2c > /dev/null; then
    echo "skip install aria2..."
else
    echo "sudo apt install aria2"
    sudo apt install aria2
fi

echo "aria2c -i $URL_FILE"
aria2c -i $URL_FILE

echo "sudo chown $USER:$USER $TOOLCAHIN_BASE"
sudo chown $USER:$USER $TOOLCAHIN_BASE

if which pv > /dev/null; then
    echo "skip install pv..."
else
    echo "sudo apt install pv"
    sudo apt install pv
fi

echo "" >> ~/.bashrc
echo "# gnu arm toolchain" >> ~/.bashrc
for i in $(echo $ARM_TARGETS | tr ":" " ")
do
    pv gcc-arm-${ARM_VERSION}-${HOSTTYPE}-${i}.tar.xz | tar Jxp -C $TOOLCAHIN_BASE
    ln -s $TOOLCAHIN_BASE/gcc-arm-${ARM_VERSION}-${HOSTTYPE}-${i} $TOOLCAHIN_BASE/${i}
    echo export PATH="\$PATH:$TOOLCAHIN_BASE/${i}/bin" >> ~/.bashrc
done
