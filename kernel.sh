#!/usr/bin/env bash
# Copyright (C) 2018 Raphiel Rollerscaperers (raphielscape)
# SPDX-License-Identifier: GPL-3.0-or-later

# Init da wae
WORKER=semaphore

    source "${HOME}/scripts/env"

   



    check_gcc_toolchain


# Set Kerneldir Plox
if [[ -z ${KERNELDIR} ]]; then
    echo "Please set KERNELDIR"
    exit 1
fi

# How much jobs we need?
if [[ -z "${JOBS}" ]]; then
    export JOBS="$(grep -c '^processor' /proc/cpuinfo)"
fi

# Toolchain Thrower
export TCVERSION1="$(${CROSS_COMPILE}gcc --version | head -1 |\
awk -F '(' '{print $2}' | awk '{print tolower($1)}')"

export TCVERSION2="$(${CROSS_COMPILE}gcc --version | head -1 |\
awk -F ')' '{print $2}' | awk '{print tolower($1)}')"

# Zipname
if [[ ${branch} == MIUI ]]; then
    export ZIPNAME="kat-miui-$(date +%Y%m%d-%H%M).zip"
elif [[ ${CC} == Clang ]]; then
    export ZIPNAME="kat-clang-oreo-$(date +%Y%m%d-%H%M).zip"
else
    export ZIPNAME="SK-mido-oreo-$(date +%Y%m%d-%H%M).zip"
fi

# Final Zip
export FINAL_ZIP="${ZIP_DIR}/${ZIPNAME}"

# Prepping
colorize "${RED}"
[ ! -d "${ZIP_DIR}" ] && mkdir -pv ${ZIP_DIR}
[ ! -d "${OUTDIR}" ] && mkdir -pv ${OUTDIR}
decolorize

# Link out directory to cache directory as per Semaphore documentation

  ln -s ${SEMAPHORE_CACHE_DIR}/out ${KERNELDIR}/out


# Here we go
cd "${SRCDIR}"

# Delett old image
colorize "${RED}"
delett ${IMAGE}
decolorize

# How 2 be Mr.Proper 101
if [[ "$@" =~ "mrproper" ]]; then
    ${MAKE} mrproper
fi

# How 2 cleanups things 101
if [[ "$@" =~ "clean" ]]; then
    ${MAKE} clean
fi

# Relatable
colorize "${CYAN}"

#export CLANG_PATH=~/clang/clang-r328903/bin
#export PATH=${CLANG_PATH}:${PATH}
#export CLANG_TRIPLE=aarch64-linux-gnu-
#export TCHAIN_PATH="${TOOLCHAIN}/bin/aarch64-opt-linux-android-"
#export CROSS_COMPILE="${CCACHE} ${TCHAIN_PATH}"
#export CLANG_TCHAIN="~/clang/clang-r328903/bin/clang"
#export KBUILD_COMPILER_STRING="$(${CLANG_TCHAIN} --version | head -n 1 | perl -pe 's/\(http.*?\)//gs' | sed -e 's/  */ /g')"


${MAKE} strakz_defconfig
decolorize

START=$(date +"%s")
header "Using ${JOBS} threads to compile" "${LIGHTCYAN}"

colorize ${LIGHTRED}
#${MAKE} CC=clang -j${JOBS}
#${MAKE} CC=clang -j${JOBS} dtbs
${MAKE} -j${JOBS}
${MAKE} -j${JOBS} dtbs
decolorize

exitCode="$?"
END=$(date +"%s")

DIFF=$(($END - $START))

# AnyKernel cleanups
header "Bringing-up AnyKernel~"
colorize ${YELLOW}


    cd ${ANYKERNEL} >> /dev/null
      delett zImage
      delett ".git"
    cd ${ANYKERNEL}/patch >> /dev/null
      delett *
    cd - >> /dev/null
  
decolorize

# Copy the image to AnyKernel
header "Copying kernel image..." "${BLUE}"
colorize ${LIGHTCYAN}
    copy "${IMAGE}" "${ANYKERNEL}/kernel"
    copy "${DTB_TREBLE}" "${ANYKERNEL}/treble/${DTB_T}"
    copy "${DTB_NONTREBLE}" "${ANYKERNEL}/nontreble/${DTB_NT}"
decolorize
cd - >> /dev/null

# Delett old modules if exists and it's MIUI
if [[ ${branch} == MIUI ]]; then
    delett "${MODULES}"
fi

# Copy modules used by MIUI
if [[ ${branch} == MIUI ]]; then
  header "Copying modules for MehUI..." "${BLUE}"
    copy "${OUTDIR}/block/test-iosched.ko" "${MODULES}"
    copy "${OUTDIR}/crypto/ansi_cprng.ko" "${MODULES}"
    copy "${OUTDIR}/drivers/char/rdbg.ko" "${MODULES}"
    copy "${OUTDIR}/drivers/input/evbug.ko" "${MODULES}"
    copy "${OUTDIR}/drivers/mmc/card/mmc_block_test.ko" "${MODULES}"
    copy "${OUTDIR}/drivers/mmc/card/mmc_test.ko" "${MODULES}"
    copy "${OUTDIR}/drivers/net/wireless/ath/wil6210/wil6210.ko" "${MODULES}"
    copy "${OUTDIR}/drivers/scsi/ufs/ufs_test.ko" "${MODULES}"
    copy "${OUTDIR}/drivers/video/backlight/backlight.ko" "${MODULES}"
    copy "${OUTDIR}/drivers/video/backlight/lcd.ko" "${MODULES}"
    copy "${OUTDIR}/drivers/video/backlight/generic_bl.ko" "${MODULES}"
    copy "${OUTDIR}/drivers/spi/spidev.ko" "${MODULES}"
    copy "${OUTDIR}/net/bridge/br_netfilter.ko" "${MODULES}"
    copy "${OUTDIR}/net/ipv4/tcp_htcp.ko" "${MODULES}"
    copy "${OUTDIR}/drivers/staging/prima/wlan.ko" "${MODULES}"
    mkdir "${MODULES}/pronto"
    copy "${MODULES}/wlan.ko" "${MODULES}/pronto/pronto_wlan.ko"
fi

# Zip the wae
header "Zipping AnyKernel..." "${BLUE}"
cd ${ANYKERNEL}
   colorize "${CYAN}"
   command zip -rT9 ${FINAL_ZIP} *
   decolorize
cd - >> /dev/null

# Finalize the zip down


echo -e "$ZIPNAME zip can be found at $FINAL_ZIP";
echo -e "Uploading ${ZIPNAME} to https://transfer.sh/";
transfer "${FINAL_ZIP}";
else
echo -e "Zip Creation Failed =(";
fi # FINAL_ZIP check 
