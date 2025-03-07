# Certipy Docker Image

This repository provides a minimal, portable Docker image for running [Certipy](https://github.com/ly4k/Certipy), a tool for Active Directory Certificate Services enumeration and abuse.

## Features

- **Minimal Size**: Multi-stage build process to keep the image small
- **Portable**: Runs on any system with Docker, regardless of Python version or dependencies
- **Isolated**: No impact on host system libraries
- **Easy to Use**: Simple wrapper script to run Certipy commands

## Quick Start

### Build the Image

```bash
# Clone this repository
git clone https://github.com/toramanemre/certipy-docker.git
cd certipy-docker

# Build the Docker image
./build-certipy.sh
```

### Run Certipy

```bash
# Run certipy with the wrapper script
./run-certipy.sh --help

# Example: Finding certificates
./run-certipy.sh find -u user@domain.local -p Password123 -dc-ip 10.10.10.10

# Example: Request a certificate
./run-certipy.sh req -u user@domain.local -p Password123 -ca ca-name -template template-name
```

## Offline Usage

For environments without internet access:

1. Build the image on a machine with internet:
   ```bash
   ./build-certipy.sh
   ```

2. Save the Docker image to a file:
   ```bash
   docker save certipy > certipy.tar
   ```

3. Transfer the tar file to the target machine

4. Load the Docker image:
   ```bash
   docker load < certipy.tar
   ```

5. Run Certipy as normal:
   ```bash
   ./run-certipy.sh [command]
   ```

## Directory Mounting

To access local files or save output, mount directories into the container:

```bash
docker run --rm -v $(pwd):/workspace -w /workspace certipy find -u user@domain.local -p Password123
```

## Dockerfile

The Dockerfile uses a multi-stage build process:

1. **Builder Stage**: 
   - Installs build dependencies
   - Clones and installs Certipy and its requirements
   - Sets up Python virtual environment

2. **Final Stage**:
   - Starts with a clean base image
   - Copies only the necessary files from the builder stage
   - Installs minimal runtime dependencies

## Credits

- [Certipy](https://github.com/ly4k/Certipy) by Oliver Lyak (ly4k)

## License

This Docker wrapper is released under the same license as Certipy (MIT).

## Disclaimer

This tool is provided for educational and testing purposes only. Always ensure you have proper authorization before using it against any systems.
