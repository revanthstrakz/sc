#!/usr/bin/env bash
# Copyright (C) 2018 Raphiel Rollerscaperers (raphielscape)
# SPDX-License-Identifier: GPL-3.0-or-later

source "${HOME}/scripts/env"

# Export Kernel Directory
export KERNELDIR=${HOME}/MiDo.

# Some alias
function clone() {
  command git clone --depth 1 "${@}"
}

# Validate things for proper configurations
if [[ ${WORKER} == semaphore ]]; then
  install-package ccache bc bash libncurses5-dev git-core gnupg flex bison gperf build-essential \
  zip curl libc6-dev ncurses-dev binfmt-support libllvm-3.6-ocaml-dev llvm-3.6 llvm-3.6-dev llvm-3.6-runtime \
  cmake automake autogen autoconf autotools-dev libtool shtool python m4 gcc libtool zlib1g-dev
fi

# Clone needed components
clone https://github.com/revanthstrakz/ak2.git ${KERNELDIR}/SK/aroma/anykernel
clone https://github.com/krasCGQ/aarch64-linux-android.git --branch "opt-linaro-7.x" ${TOOLCHAIN}
clone https://github.com/Adesh15/platform_prebuilts_clang_host_linux-x86.git ~/clang
# clone https://github.com/kenny3fcb/aarch64-linux-gnu.git ${TOOLCHAIN}

# Going to start
cd ${KERNELDIR}

# Play Wires bois
${HOME}/scripts/kernel.sh
