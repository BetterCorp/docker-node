# docker-node

Better Node.js Docker images with multiple specialized variants for different development and production needs.

## Available Images

### Base Images
- `betterweb/node:latest` - Latest stable Node.js on Alpine Linux (highest published supported major)
- `betterweb/node:24` - Node.js 24.x (major version)
- `betterweb/node:24.x.y` - Specific Node.js version

### Development Variants
- `betterweb/node:dev` - Development image with additional tools (not for production)
- `betterweb/node:dev-24` - Development image for Node.js 24.x
- `betterweb/node:dev-24.x.y` - Development image for specific version

### DevContainer Variants
- `betterweb/node:devcontainer-latest` - VS Code DevContainer with development tools
- `betterweb/node:devcontainer-24` - DevContainer for Node.js 24.x
- `betterweb/node:devcontainer-24.x.y` - DevContainer for specific version

### Docker-in-Docker (DIND) Variants
- `betterweb/node:dind-latest` - Node.js with Docker and Docker Compose support
- `betterweb/node:dind-24` - DIND for Node.js 24.x
- `betterweb/node:dind-24.x.y` - DIND for specific version

## Usage

### Running from Command Line

#### Basic Node.js Container
```bash
# Run latest Node.js version
docker run -it betterweb/node:latest

# Run specific version
docker run -it betterweb/node:24

# Run with mounted volume for development
docker run -it -v $(pwd):/app -w /app betterweb/node:24 npm start

# Run with port mapping
docker run -it -p 3000:3000 -v $(pwd):/app -w /app betterweb/node:24 node server.js
```

#### Development Container
```bash
# Interactive development environment
docker run -it -v $(pwd):/app -w /app betterweb/node:dev-24 bash

# Install packages with native dependencies
docker run -it -v $(pwd):/app -w /app betterweb/node:dev-24 npm install bcrypt sharp

# Run development server with live reload
docker run -it -p 3000:3000 -v $(pwd):/app -w /app betterweb/node:dev-24 npm run dev
```

#### Docker-in-Docker Container
```bash
# Run with Docker socket access (Linux/macOS)
docker run -it --privileged -v /var/run/docker.sock:/var/run/docker.sock betterweb/node:dind-24 bash

# Run CI/CD pipeline
docker run -it --privileged -v $(pwd):/app -w /app betterweb/node:dind-24 npm test
```

#### DevContainer Usage
```bash
# Interactive DevContainer environment
docker run -it -v $(pwd):/workspace -w /workspace betterweb/node:devcontainer-24 bash

# With VS Code DevContainer extension (use in .devcontainer/devcontainer.json)
```

### Dockerfile Examples

#### Basic Node.js Application
```dockerfile
FROM betterweb/node:24
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY . .
EXPOSE 3000
CMD ["node", "index.js"]
```

### Development Environment
```dockerfile
FROM betterweb/node:dev-24
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
CMD ["npm", "run", "dev"]
```

### Using install_packages for Native Dependencies
The dev variant includes a helper script for installing packages with native dependencies:
```dockerfile
FROM betterweb/node:dev-24
WORKDIR /app
COPY package*.json ./
# Use install_packages for packages that need compilation
RUN install_packages bcrypt canvas sharp
COPY . .
CMD ["npm", "run", "dev"]
```

### Docker-in-Docker for CI/CD
```dockerfile
FROM betterweb/node:dind-24
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
# Can run docker commands within this container
RUN docker --version
CMD ["npm", "test"]
```

### DevContainer Configuration
For VS Code DevContainers, use in `.devcontainer/devcontainer.json`:
```json
{
  "name": "Node.js DevContainer",
  "image": "betterweb/node:devcontainer-24",
  "features": {},
  "forwardPorts": [3000],
  "postCreateCommand": "npm install"
}
```

## Image Features

### Base Image (`betterweb/node`)
- Alpine Linux base for minimal size
- Node.js installed from official sources
- `gosu` for proper user privilege handling
- Custom entrypoint script
- Non-root `node` user

### Development Image (`dev-*`)
- Built on top of base image
- Includes `install_packages` script for easy npm package installation with native dependencies
- `install_packages` temporarily installs Python 3, make and g++ during Docker builds
- **Not recommended for production use**

### DevContainer Image (`devcontainer-*`)
- Debian-based for broader tool compatibility
- Pre-installed development tools (git, curl, make, g++, python3)
- Sudo access for the `node` user
- Optimized for VS Code DevContainer environments

### DIND Image (`dind-*`)
- Built on top of base Alpine image
- Docker Engine and Docker CLI installed
- Docker Compose v2 support
- Runs dockerd in background
- User added to docker group

## Version Matrix

Images are built for multiple Node.js versions:
- **Base images**: Node.js 24.x and 26.x
- **Specialized variants** (dev, devcontainer, dind): Node.js 24.x and 26.x
- **Update schedule**: Monthly on the 1st of each month

## Architecture Support

Multi-platform images supporting:
- `linux/amd64` (x86_64)
- `linux/arm64/v8` (ARM64)

## Security

- The base/dev entrypoint drops root to `node` (UID 1000); explicit non-root users are preserved. Dockerfile build steps still run as root.
- Devcontainers include sudo; DIND is privileged development tooling, not a production security boundary.
- Regular security updates through automated builds
- Minimal attack surface with Alpine Linux base (except devcontainer)
- No secrets or credentials included in images

## Build Process

Images are automatically built and published via GitHub Actions:
1. **prepare-matrix**: Determines Node.js versions and platforms
2. **build**: Builds base images for all versions
3. **build-dev**: Builds development variants (limited versions)
4. **build-devcontainers**: Builds VS Code DevContainer variants (limited versions)
5. **build-dind**: Builds Docker-in-Docker variants (limited versions)

## Contributing

This repository contains:
- `Dockerfile` - Base Node.js image
- `Dockerfile.dev` - Development variant
- `Dockerfile.devcontainer` - VS Code DevContainer variant
- `Dockerfile.dind` - Docker-in-Docker variant
- `.github/workflows/buildAndPub.yml` - Automated build pipeline

## License

This project follows the same license as the official Node.js Docker images.

## Production image policy

BetterCorp applications use `code.bettercorp.dev/bettercorp/docker-node:24`
(or its `betterweb/node:24` mirror), preserving the custom privilege-dropping
entrypoint. UUST uses Node 24 LTS; do not replace this with `node:22` or bypass
the entrypoint. Application files should be root-owned and read-only to the
runtime user, with writable directories created explicitly when needed.
`USER node` is supported. These are Unix user/filesystem limits, not Node's
experimental permission model. Docker image builders must still use the official
Node image as the upstream source for this BetterCorp image.

The publishing matrix chooses the highest numeric patch with available Alpine
and Bookworm images for Node 24 and 26. Base images are tested for privilege
dropping and non-root startup before publishing. The merged manifest is retained
as a workflow artifact; releases/tags require a separately verified, signed
maintainer action. DockerHub remains an optional mirror: a rate limit or mirror failure does not
block the primary registry or dependent images, and the manifest omits mirror
tags unless their publication succeeded.

Validate locally with `docker build -t betterweb/node:permission-test .` and
`tests/permissions.sh betterweb/node:permission-test`.
