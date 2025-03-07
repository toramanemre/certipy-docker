#!/bin/bash
# Build script for Certipy Docker image

# Create a directory for the build
mkdir -p certipy-docker
cd certipy-docker

# Create the Dockerfile
cat > Dockerfile << 'EOF'
FROM python:3.9-slim AS builder

# Install build dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    gcc \
    python3-dev \
    libkrb5-dev \
    && rm -rf /var/lib/apt/lists/*

# Create a virtual environment
RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Clone and install Certipy
RUN git clone --depth=1 https://github.com/ly4k/Certipy.git /opt/certipy
WORKDIR /opt/certipy
RUN pip install --no-cache-dir -e .
RUN pip install git+https://github.com/ly4k/ldap3

# Cleanup unnecessary files
RUN find /opt/venv -name __pycache__ -type d -exec rm -rf {} +

# Final stage - minimal runtime image
FROM python:3.9-slim

# Copy only the virtual environment from the builder
COPY --from=builder /opt/venv /opt/venv
COPY --from=builder /opt/certipy /opt/certipy

# Set up environment
ENV PATH="/opt/venv/bin:$PATH"
WORKDIR /opt/certipy

# Install only runtime dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    libkrb5-3 \
    && rm -rf /var/lib/apt/lists/*

ENTRYPOINT ["certipy"]
CMD ["--help"]
EOF

# Build the Docker image
echo "Building Certipy Docker image..."
docker build -t certipy .

# Show the image size
echo -e "\nImage size:"
docker images certipy

# Create a usage script
cat > run-certipy.sh << 'EOF'
#!/bin/bash
# Run Certipy from Docker container

# Check if command is provided
if [ $# -eq 0 ]; then
    docker run --rm certipy --help
else
    docker run --rm certipy "$@"
fi
EOF

chmod +x run-certipy.sh

echo -e "\nDone! You can now use Certipy with: ./run-certipy.sh [command]"
echo "Example: ./run-certipy.sh find -u user@domain.local -p Password123 -dc-ip 10.10.10.10"
