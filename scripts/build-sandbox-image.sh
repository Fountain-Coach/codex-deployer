#!/usr/bin/env bash
set -euo pipefail

# build-sandbox-image.sh
# -----------------------
# Assemble a minimal Ubuntu 22.04 rootfs with Swift 6 and media tools.
# The script relies on debootstrap and produces both a tarball and a
# qcow2 snapshot suitable for micro-VM execution.  A tools.json manifest
# describing the resulting image is emitted alongside the artifacts.
#
# For usage and maintenance details, consult the toolsmith documentation.

UBUNTU_RELEASE="jammy"
IMAGE_NAME="sandbox-ubuntu22.04"
ROOTFS_DIR="${ROOTFS_DIR:-rootfs}"
OUTPUT_DIR="${OUTPUT_DIR:-.}"
TARBALL="$OUTPUT_DIR/${IMAGE_NAME}.tar.gz"
QCOW2="$OUTPUT_DIR/${IMAGE_NAME}.qcow2"
MANIFEST="$OUTPUT_DIR/tools.json"
EXTRA_PKGS=""

# Optional multimedia tooling
if [[ "${INCLUDE_MUSIC:-0}" == "1" ]]; then
  EXTRA_PKGS="csound lilypond"
fi

command -v debootstrap >/dev/null 2>&1 || { echo "debootstrap required" >&2; exit 1; }
command -v qemu-img >/dev/null 2>&1 || { echo "qemu-img required" >&2; exit 1; }
command -v curl >/dev/null 2>&1 || { echo "curl required" >&2; exit 1; }
command -v jq >/dev/null 2>&1 || { echo "jq required" >&2; exit 1; }

# Determine latest Swift release
SWIFT_TAG=$(curl -fsSL https://api.github.com/repos/swiftlang/swift/releases/latest | jq -r '.tag_name')
SWIFT_VERSION=${SWIFT_TAG#swift-}
SWIFT_VERSION=${SWIFT_VERSION%-RELEASE}

# Clean any previous build
rm -rf "$ROOTFS_DIR" "$TARBALL" "$QCOW2"

# ---------------------------------------------------------------------------
# 1. Bootstrap minimal Ubuntu rootfs
# ---------------------------------------------------------------------------

debootstrap --variant=minbase --components=main,universe "$UBUNTU_RELEASE" "$ROOTFS_DIR" \
  http://archive.ubuntu.com/ubuntu/

# ---------------------------------------------------------------------------
# 2. Install Swift and toolchain inside chroot
# ---------------------------------------------------------------------------

cat > "$ROOTFS_DIR/apt-install.sh" <<CHROOT
#!/usr/bin/env bash
set -euo pipefail
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y curl ca-certificates gnupg2 imagemagick ffmpeg exiftool pandoc libplist-utils \$EXTRA_PKGS

SWIFT_VERSION="${SWIFT_VERSION}"
SWIFT_TARBALL="swift-\${SWIFT_VERSION}-RELEASE-ubuntu22.04.tar.gz"
SWIFT_URL="https://download.swift.org/swift-\${SWIFT_VERSION}-release/ubuntu2204/swift-\${SWIFT_VERSION}-RELEASE/\${SWIFT_TARBALL}"
curl -fsSL "\${SWIFT_URL}" -o /tmp/swift.tar.gz
tar -xzf /tmp/swift.tar.gz -C /usr/local --strip-components=1
rm /tmp/swift.tar.gz
CHROOT

chmod +x "$ROOTFS_DIR/apt-install.sh"
EXTRA_PKGS="$EXTRA_PKGS" chroot "$ROOTFS_DIR" /apt-install.sh
rm "$ROOTFS_DIR/apt-install.sh"

# ---------------------------------------------------------------------------
# 3. Gather tool versions for manifest
# ---------------------------------------------------------------------------

swift_version=$(chroot "$ROOTFS_DIR" swift --version | head -n1)
magick_version=$(chroot "$ROOTFS_DIR" convert -version | head -n1)
ffmpeg_version=$(chroot "$ROOTFS_DIR" ffmpeg -version | head -n1)
exiftool_version=$(chroot "$ROOTFS_DIR" exiftool -ver)
pandoc_version=$(chroot "$ROOTFS_DIR" pandoc -v | head -n1)
plist_version=$(chroot "$ROOTFS_DIR" dpkg-query -W -f '${Version}' libplist-utils)
csound_version=$(chroot "$ROOTFS_DIR" bash -c 'command -v csound >/dev/null && csound --version | head -n1' || true)
lilypond_version=$(chroot "$ROOTFS_DIR" bash -c 'command -v lilypond >/dev/null && lilypond --version | head -n1' || true)

# ---------------------------------------------------------------------------
# 3b. Include license files
# ---------------------------------------------------------------------------

mkdir -p "$ROOTFS_DIR/usr/share/licenses"
cp -a LICENSES/. "$ROOTFS_DIR/usr/share/licenses/"

# ---------------------------------------------------------------------------
# 4. Create tarball and qcow2 snapshot
# ---------------------------------------------------------------------------

tar --numeric-owner -C "$ROOTFS_DIR" -czf "$TARBALL" .
image_sha=$(sha256sum "$TARBALL" | awk '{print $1}')

IMG_FILE=$(mktemp image.XXXXXX)
dd if=/dev/zero of="$IMG_FILE" bs=1M count=2048 >/dev/null 2>&1
mkfs.ext4 -F "$IMG_FILE" >/dev/null 2>&1
mkdir -p mnt
mount -o loop "$IMG_FILE" mnt
cp -a "$ROOTFS_DIR"/. mnt
umount mnt
qemu-img convert -f raw -O qcow2 "$IMG_FILE" "$QCOW2"
rm -f "$IMG_FILE"
qcow_sha=$(sha256sum "$QCOW2" | awk '{print $1}')

# ---------------------------------------------------------------------------
# 5. Emit manifest
# ---------------------------------------------------------------------------

cat > "$MANIFEST" <<JSON
{
  "image": {
    "name": "$IMAGE_NAME",
    "tarball": "$(basename "$TARBALL")",
    "sha256": "$image_sha",
    "qcow2": "$(basename "$QCOW2")",
    "qcow2_sha256": "$qcow_sha"
  },
  "tools": {
    "swift": "$swift_version",
    "imagemagick": "$magick_version",
    "ffmpeg": "$ffmpeg_version",
    "exiftool": "$exiftool_version",
    "pandoc": "$pandoc_version",
    "libplist": "$plist_version",
    "csound": "$csound_version",
    "lilypond": "$lilypond_version"
  },
  "operations": [
    "swiftc",
    "convert",
    "ffmpeg",
    "exiftool",
    "pandoc",
    "plistutil",
    "csound",
    "lilypond"
  ]
}
JSON

echo "[build] Image: $TARBALL (sha256 $image_sha)"
echo "[build] QCOW2: $QCOW2 (sha256 $qcow_sha)"
echo "[build] Manifest written to $MANIFEST"
# © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
