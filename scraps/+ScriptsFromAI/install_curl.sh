#!/bin/bash

set -e  # Exit on error
set -o pipefail  # Exit on first error in a pipeline

# Define source directory
SRC_DIR="/media/akienm/OneDrive/AkiensWorkshop/dev/src"
BUILD_DIR="$SRC_DIR/curl"

echo "Cloning cURL repository into $BUILD_DIR..."
if [[ -d "$BUILD_DIR" ]]; then
    echo "Directory exists. Pulling latest changes..."
    cd "$BUILD_DIR"
    git pull
else
    git clone --depth=1 https://github.com/curl/curl.git "$BUILD_DIR"
    cd "$BUILD_DIR"
fi

# Get the latest stable tag
LATEST_TAG=$(git tag -l --sort=-v:refname | grep '^curl-' | head -n 1)
if [[ -z "$LATEST_TAG" ]]; then
    echo "Error: No release tags found."
    exit 1
fi
echo "Checking out latest stable release: $LATEST_TAG"
git checkout "$LATEST_TAG"

echo "Building cURL..."
./buildconf || autoreconf -fi
./configure --prefix=/usr/local --with-ssl
make -j"$(nproc)"
sudo make install

# Ensure the new cURL is used
echo "Updating shared libraries..."
sudo ldconfig

# Verify installation
echo "Installed cURL version:"
/usr/local/bin/curl --version

echo "Setting up PATH..."
if ! grep -q 'export PATH="/usr/local/bin:$PATH"' ~/.bashrc; then
    echo 'export PATH="/usr/local/bin:$PATH"' >> ~/.bashrc
fi
source ~/.bashrc

echo "cURL installation complete!"

