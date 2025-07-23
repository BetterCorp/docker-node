# docker-node

Better Node.js Docker images with multiple specialized variants for different development and production needs.

## Available Images

### Base Images
- `betterweb/node:latest` - Latest stable Node.js on Alpine Linux (currently 24.x)
- `betterweb/node:24` - Node.js 24.x (major version)
- `betterweb/node:24.0.0` - Specific Node.js version

### Development Variants
- `betterweb/node:dev` - Development image with additional tools (not for production)
- `betterweb/node:dev-24` - Development image for Node.js 24.x
- `betterweb/node:dev-24.0.0` - Development image for specific version

### DevContainer Variants
- `betterweb/node:devcontainer-latest` - VS Code DevContainer with development tools
- `betterweb/node:devcontainer-24` - DevContainer for Node.js 24.x
- `betterweb/node:devcontainer-24.0.0` - DevContainer for specific version

### Docker-in-Docker (DIND) Variants
- `betterweb/node:dind-latest` - Node.js with Docker and Docker Compose support
- `betterweb/node:dind-24` - DIND for Node.js 24.x
- `betterweb/node:dind-24.0.0` - DIND for specific version

## Usage

### Basic Node.js Application
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
RUN install_packages "bcrypt canvas sharp"
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
- Pre-configured build tools (python, make, g++) for compiling native modules
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
- **Base images**: All supported Node.js versions (currently 18.x, 20.x, 21.x, 22.x, 23.x, 24.x)
- **Specialized variants** (dev, devcontainer, dind): Latest 3 major Node.js versions (currently 22.x, 23.x, 24.x)
- **Update schedule**: Monthly on the 1st of each month

## Architecture Support

Multi-platform images supporting:
- `linux/amd64` (x86_64)
- `linux/arm64/v8` (ARM64)

## Security

- All images run as non-root `node` user by default
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