
#!/bin/bash

# Variables
CURL_VERSION="8.11.0"
SOURCE_DIR="$HOME/repos"
CURL_TARBALL="curl-${CURL_VERSION}.tar.gz"
CURL_URL="https://curl.se/download/${CURL_TARBALL}"

# Create source directory if it doesn't exist
mkdir -p "$SOURCE_DIR"

# Change to source directory
cd "$SOURCE_DIR" || { echo "Failed to enter $SOURCE_DIR"; exit 1; }

# Download curl source tarball
echo "Downloading curl ${CURL_VERSION}..."
if ! curl -LO "$CURL_URL"; then
    echo "Failed to download $CURL_URL"
    exit 1
fi

# Extract the tarball
echo "Extracting ${CURL_TARBALL}..."
tar -xvf "$CURL_TARBALL" || { echo "Failed to extract $CURL_TARBALL"; exit 1; }

# Enter the source directory
cd "curl-${CURL_VERSION}" || { echo "Failed to enter curl-${CURL_VERSION} directory"; exit 1; }

# Install required build tools
echo "Installing build tools..."
sudo apt update
sudo apt install -y build-essential libssl-dev zlib1g-dev || { echo "Failed to install dependencies"; exit 1; }

# Configure the build
echo "Configuring the build..."
if ! ./configure --with-ssl; then
    echo "Configuration failed"
    exit 1
fi

# Build curl
echo "Building curl..."
if ! make -j"$(nproc)"; then
    echo "Build failed"
    exit 1
fi

# Install curl
echo "Installing curl..."
if ! sudo make install; then
    echo "Installation failed"
    exit 1
fi

# Verify the installation
echo "Verifying curl installation..."
if curl --version | grep -q "${CURL_VERSION}"; then
    echo "curl ${CURL_VERSION} installed successfully."
else
    echo "curl installation verification failed."
    exit 1
fi
