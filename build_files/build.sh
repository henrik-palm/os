#!/bin/bash

set -ouex pipefail

### Install packages

# Packages can be installed from any enabled yum repo on the image.
# RPMfusion repos are available by default in ublue main images
# List of rpmfusion packages can be found here:
# https://mirrors.rpmfusion.org/mirrorlist?path=free/fedora/updates/39/x86_64/repoview/index.html&protocol=https&redirect=1

# this installs a package from fedora repos
dnf5 install -y tmux

# Install Firefox from Fedora repos
dnf5 install -y firefox

# Use a COPR Example:
#
# dnf5 -y copr enable ublue-os/staging
# dnf5 -y install package
# Disable COPRs so they don't end up enabled on the final image:
# dnf5 -y copr disable ublue-os/staging

##### Boot splash (Plymouth) ###################################################

# Overwrite the logo in the stock spinner theme
cp /ctx/logo.png /usr/share/plymouth/themes/spinner/watermark.png
cp /ctx/logo.png /usr/share/plymouth/themes/spinner/silverblue-watermark.png
mkdir -p /usr/share/plymouth/themes/devtheme

##### Plymouth: install custom theme and set as default ########################
set -Eeuo pipefail

THEME_NAME="darwin"
SRC_DIR="/ctx/plymouth/${THEME_NAME}"
DST_DIR="/usr/share/plymouth/themes/${THEME_NAME}"

# 1) Copy your theme into the image
if [[ ! -f "${SRC_DIR}/${THEME_NAME}.plymouth" ]]; then
  echo "ERROR: ${SRC_DIR}/${THEME_NAME}.plymouth not found"; exit 1
fi
install -d "${DST_DIR}"
cp -a "${SRC_DIR}/." "${DST_DIR}/"

# 2) Set defaults (system-wide, baked into the image)
#    /usr/lib/plymouth/plymouthd.defaults is the distro default file
cat > /usr/share/plymouth/plymouthd.defaults <<EOF
# Distribution defaults. Changes to this file will get overwritten during
# upgrades.
[Daemon]
Theme=${THEME_NAME}
ShowDelay=0
DeviceTimeout=8
UseSimpledrmNoLuks=1
EOF

###############################################################################
### Branding: replace Fedora pixmap logos used by GDM & GNOME About ###########
###############################################################################

# Expect two source images in the repo at /ctx/
LOGO64_SRC="/ctx/logo-64.png"
LOGO256_SRC="/ctx/logo-256.png"

if [[ ! -f "${LOGO64_SRC}" ]] || [[ ! -f "${LOGO256_SRC}" ]]; then
  echo "ERROR: Missing logo assets."
  echo "Ensure both logo-64.png and logo-256.png are next to build.sh in the repo."
  exit 1
fi

install -d -m 0755 /usr/share/pixmaps

# Map each destination to the correct source logo
declare -A PIXMAP_MAP=(
  ["/usr/share/pixmaps/fedora-gdm-logo.png"]="${LOGO64_SRC}"
  ["/usr/share/pixmaps/fedora-logo-icon.png"]="${LOGO256_SRC}"
  ["/usr/share/pixmaps/fedora_logo_med.png"]="${LOGO256_SRC}"
  ["/usr/share/pixmaps/fedora-logo.png"]="${LOGO256_SRC}"
  ["/usr/share/pixmaps/fedora-logo-small.png"]="${LOGO64_SRC}"
  ["/usr/share/pixmaps/fedora-logo-sprite.png"]="${LOGO256_SRC}"
  ["/usr/share/pixmaps/fedora_whitelogo_med.png"]="${LOGO256_SRC}"
  ["/usr/share/pixmaps/system-logo-white.png"]="${LOGO256_SRC}"
)

# Copy each logo into place
for target in "${!PIXMAP_MAP[@]}"; do
  src="${PIXMAP_MAP[$target]}"
  install -D -m 0644 "${src}" "${target}"
done

# (Optional) also provide a generic distributor logo for GNOME Settings → About
# install -D -m 0644 "${LOGO256_SRC}" /usr/share/pixmaps/distributor-logo.png
# install -D -m 0644 "${LOGO256_SRC}" /usr/share/icons/hicolor/256x256/apps/distributor-logo.png
###############################################################################


###############################################################################

#### Example for enabling a System Unit File

systemctl enable podman.socket
