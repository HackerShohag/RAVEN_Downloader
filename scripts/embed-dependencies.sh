#!/usr/bin/env bash

set -euo pipefail

echo "=== Installing embedded yt-dlp and ffmpeg ==="

: "${INSTALL_DIR:?Clickable must provide INSTALL_DIR}"
: "${ARCH:?Clickable must provide ARCH}"
: "${ARCH_TRIPLET:?Clickable must provide ARCH_TRIPLET}"

target_dir="$INSTALL_DIR"
ffmpeg_bin_dir="$target_dir/lib/$ARCH_TRIPLET/bin"
ffmpeg_lib_dir="$target_dir/lib/$ARCH_TRIPLET"
ffmpeg_version="8.0.1"
ffmpeg_archive="/tmp/ffmpeg-${ffmpeg_version}.tar.xz"
ffmpeg_build_dir="/tmp/ffmpeg-build"

mkdir -p "$target_dir/lib/python3/dist-packages" "$ffmpeg_bin_dir" "$ffmpeg_lib_dir"

pip3 install \
  --target="$target_dir/lib/python3/dist-packages" \
  --upgrade \
  --no-cache-dir \
  --no-warn-script-location \
  yt-dlp
PYTHONPATH="$target_dir/lib/python3/dist-packages" \
  python3 -c 'import yt_dlp; print("Embedded yt-dlp version: " + yt_dlp.version.__version__)'

case "$ARCH" in
  arm64)
    ffmpeg_arch_args=(--arch=aarch64 --enable-cross-compile --cross-prefix=aarch64-linux-gnu- --target-os=linux)
    ;;
  armhf)
    ffmpeg_arch_args=(--arch=arm --cpu=armv7-a --enable-cross-compile --cross-prefix=arm-linux-gnueabihf- --target-os=linux)
    ;;
  amd64)
    ffmpeg_arch_args=(--arch=x86_64)
    ;;
  *)
    echo "Unsupported Clickable architecture: $ARCH" >&2
    exit 1
    ;;
esac

echo "Downloading and compiling ffmpeg ${ffmpeg_version} for ${ARCH}"
wget -q -O "$ffmpeg_archive" "https://ffmpeg.org/releases/ffmpeg-${ffmpeg_version}.tar.xz"
rm -rf "$ffmpeg_build_dir"
mkdir -p "$ffmpeg_build_dir"
tar -xJf "$ffmpeg_archive" -C "$ffmpeg_build_dir" --strip-components=1

pushd "$ffmpeg_build_dir" >/dev/null
./configure \
  --prefix="$target_dir" \
  --bindir="$ffmpeg_bin_dir" \
  --libdir="$ffmpeg_lib_dir" \
  "${ffmpeg_arch_args[@]}" \
  --enable-shared \
  --enable-gpl \
  --enable-small \
  --disable-doc \
  --disable-htmlpages \
  --disable-manpages \
  --disable-podpages \
  --disable-txtpages \
  --disable-debug \
  --disable-static \
  --disable-programs \
  --enable-ffmpeg \
  --enable-ffprobe
make -j"$(nproc)"
make install
popd >/dev/null

test -x "$ffmpeg_bin_dir/ffmpeg"
file "$ffmpeg_bin_dir/ffmpeg"

host_arch="$(uname -m)"
can_run_ffmpeg=false
case "$ARCH" in
  arm64)
    [[ "$host_arch" == "aarch64" || "$host_arch" == "arm64" ]] && can_run_ffmpeg=true
    ;;
  armhf)
    [[ "$host_arch" == "armv7l" || "$host_arch" == "armv6l" || "$host_arch" == "armhf" ]] && can_run_ffmpeg=true
    ;;
  amd64)
    [[ "$host_arch" == "x86_64" || "$host_arch" == "amd64" ]] && can_run_ffmpeg=true
    ;;
esac

if [[ "$can_run_ffmpeg" == true ]]; then
  LD_LIBRARY_PATH="$ffmpeg_lib_dir${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}" \
    "$ffmpeg_bin_dir/ffmpeg" -version
else
  echo "Skipping ffmpeg runtime check for target architecture ${ARCH} on host ${host_arch}"
fi

rm -rf "$ffmpeg_build_dir" "$ffmpeg_archive"
echo "=== Embedded dependencies installed ==="
