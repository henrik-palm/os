#!/bin/bash

set -ouex pipefail

### Install packages

# Packages can be installed from any enabled yum repo on the image.
# RPMfusion repos are available by default in ublue main images
# List of rpmfusion packages can be found here:
# https://mirrors.rpmfusion.org/mirrorlist?path=free/fedora/updates/39/x86_64/repoview/index.html&protocol=https&redirect=1

# this installs a package from fedora repos
dnf5 install -y tmux 

# Use a COPR Example:
#
# dnf5 -y copr enable ublue-os/staging
# dnf5 -y install package
# Disable COPRs so they don't end up enabled on the final image:
# dnf5 -y copr disable ublue-os/staging

### SofusA

mkdir -p $(realpath /root)
mkdir -p $(realpath /opt)
mkdir -p $(realpath /usr/local)

dnf5 -y copr enable scottames/ghostty
dnf5 install -yq ghostty

# Node
dnf5 install -yq npm
npm config --global set prefix "/usr"

# Rust
dnf5 install -yq cargo rust-analyzer rustfmt clippy

export CARGO_HOME=/tmp/cargo
mkdir -p "$CARGO_HOME"
 
# Steel
# dnf5 install -yq rust-openssl-sys-devel
# git clone https://github.com/mattwparas/steel.git
# cd steel
# cargo install --root /usr --path .
# cargo install --root /usr --path crates/steel-language-server
# cargo install --root /usr --path crates/cargo-steel-lib
# OPENSSL_NO_VENDOR=1 cargo install --root /usr --path crates/forge
# cd cogs
# cargo run -- install.scm
# cd ../..
# rm -rf steel

# cli-dungeon
# wget https://github.com/SofusA/cli-dungeon/releases/latest/download/cli-dungeon-x86_64-unknown-linux-gnu.tar.gz
# tar -xf cli-dungeon-x86_64-unknown-linux-gnu.tar.gz
# mv cli-dungeon /usr/bin
# rm cli-dungeon-x86_64-unknown-linux-gnu.tar.gz

# Cargo binstall
curl -L --proto '=https' --tlsv1.2 -sSf https://raw.githubusercontent.com/cargo-bins/cargo-binstall/main/install-from-binstall-release.sh | bash

# Dotnet
dnf5 install -yq dotnet-sdk-9.0 dotnet-sdk-8.0 aspnetcore-runtime-9.0 azure-cli

DOTNET_CLI_HOME=/usr/lib/dotnet
mkdir -p "$DOTNET_CLI_HOME"
dotnet tool install --tool-path /usr/bin csharpier
npm i -gq --prefix /usr azure-functions-core-tools
wget -qO- https://aka.ms/install-artifacts-credprovider.sh | bash
 
# csharp
wget https://github.com/SofusA/csharp-language-server/releases/latest/download/csharp-language-server-x86_64-unknown-linux-gnu.zip
unzip csharp-language-server-x86_64-unknown-linux-gnu.zip
mv csharp-language-server /usr/bin
rm csharp-language-server-x86_64-unknown-linux-gnu.zip 
mkdir -p /usr/lib/csharp-language-server
# cargo install --root /usr --git https://github.com/SofusA/csharp-language-server
csharp-language-server --download --directory /usr/lib/csharp-language-server

# vscode
rpm --import https://packages.microsoft.com/keys/microsoft.asc
echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\nautorefresh=1\ntype=rpm-md\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" | sudo tee /etc/yum.repos.d/vscode.repo > /dev/null
dnf5 install -yq code

# powershell
curl https://packages.microsoft.com/config/rhel/9/prod.repo | sudo tee /etc/yum.repos.d/microsoft.repo
mkdir -p /opt/microsoft/powershell/7/
mkdir -p /usr/local/share/man/man1/
dnf5 install -yq powershell
rm /usr/bin/pwsh
mv /opt/microsoft/powershell /usr/lib
ln -s /usr/lib/powershell/7/pwsh /usr/bin/pwsh

# Language servers
npm i -gq --prefix /usr prettier @tailwindcss/language-server vscode-langservers-extracted typescript-language-server typescript
npm i -gq --prefix /usr @angular/cli @angular/language-service typescript @angular/language-server
# wget $(curl -s https://api.github.com/repos/tekumara/typos-lsp/releases/latest | jq -r '.assets[] | select(.name | test(".*x86_64-unknown-linux-gnu")).browser_download_url')
wget https://github.com/tekumara/typos-lsp/releases/download/v0.1.40/typos-lsp-v0.1.40-x86_64-unknown-linux-gnu.tar.gz
tar -xf typos-lsp*tar.gz
mv typos-lsp /usr/bin
rm typos-lsp*tar.gz
cargo binstall -yq --root /usr leptosfmt

## Bicep language server
wget https://github.com/Azure/bicep/releases/latest/download/bicep-langserver.zip
unzip bicep-langserver.zip -d /usr/lib/bicep-langserver
echo -e "#!/usr/bin/env bash\nexec dotnet /usr/lib/bicep-langserver/Bicep.LangServer.dll" > /usr/bin/bicep-langserver
chmod +x /usr/bin/bicep-langserver
rm bicep-langserver.zip

# Shell
dnf5 install -yq zoxide atuin fd-find ripgrep skim
cargo binstall -yq --root /usr sd eza ccase
dnf5 -y copr enable lihaohong/yazi
dnf5 -yq install yazi
dnf5 -yq install cowsay kitty
dnf5 -yq install sudo-rs uutils-coreutils

# Git
dnf5 -y copr enable vdanielmo/git-credential-manager
dnf5 install -yq git-credential-manager

dnf5 install -yq gh meld
cargo binstall -yq --root /usr --strategies crate-meta-data jj-cli

wget $(curl -s https://api.github.com/repos/Cretezy/lazyjj/releases/latest | jq -r '.assets[] | select(.name | test(".*linux")).browser_download_url')
tar -xf lazyjj*tar.gz
mv lazyjj /usr/bin
rm lazyjj*tar.gz

# Helix
cargo install --root /usr --git https://github.com/nik-rev/patchy
git config --global user.email "you@example.com"
git config --global user.name "Your Name"
dnf5 install -yq clang
export HELIX_DEFAULT_RUNTIME=/usr/lib/helix/runtime
mkdir -p "$HELIX_DEFAULT_RUNTIME"
# git clone -b pull-diagnostics https://github.com/SofusA/helix-pull-diagnostics.git
git clone https://github.com/SofusA/helix-driver
cd helix-driver
# cd helix-pull-diagnostics
patchy run --confirm yes
cargo build --profile opt --locked
cp -r runtime /usr/lib/helix/
cp target/opt/hx /usr/bin/hx
cd ..
# rm -rf helix-pull-diagnostics
rm -rf helix-dirver

# Desktop
dnf5 -y copr enable yalter/niri-git
dnf5 install -yq niri wl-clipboard swayidle mako

# Remove rust and install rustup instead
dnf5 remove -yq cargo rust-analyzer rustfmt clippy
dnf5 install -yq rustup
dnf5 -y autoremove

# Qobuz player
# dnf5 install -yq rust-glib-sys-devel rust-gstreamer-devel # Qobuz player dependencies
# # cargo install --root /usr --locked --git https://github.com/sofusa/qobuz-player 
# wget https://github.com/SofusA/qobuz-player/releases/latest/download/qobuz-player-x86_64-unknown-linux-gnu.tar.gz
# tar -xf qobuz-player-x86_64-unknown-linux-gnu.tar.gz
# mv qobuz-player /usr/bin
# rm qobuz-player-x86_64-unknown-linux-gnu.tar.gz
 
# color-scheme
wget https://github.com/SofusA/color-scheme/releases/latest/download/color-scheme-x86_64-unknown-linux-gnu.zip
unzip color-scheme-x86_64-unknown-linux-gnu.zip
mv color-scheme /usr/bin
rm color-scheme-x86_64-unknown-linux-gnu.zip
 
# Playwright dependencies
dnf5 install -yq libjpeg-turbo libwebp libffi libicu


#### Example for enabling a System Unit File

systemctl enable podman.socket
