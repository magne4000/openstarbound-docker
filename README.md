# magne4000/starbound

A Docker container for running the [OpenStarbound](https://github.com/OpenStarbound/OpenStarbound) server, with automatic updates and LinuxServer-style PUID/PGID support. Designed for use on Linux and other Docker-compatible hosts.

---

## Features

- Runs the **OpenStarbound server** in Docker  
- Automatic download and update of the latest server release  
- LinuxServer-style **PUID/PGID support** for host-mounted volumes  

---

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `PUID`   | `1000`  | UID to run the server as (for host volume permissions) |
| `PGID`   | `1000`  | GID to run the server as (for host volume permissions) |

> **Note:** If `PUID` or `PGID` are not set, the container uses the default user `starbound` (UID/GID 1000).  

---

## Volumes

| Host Path | Container Path | Description |
|-----------|----------------|-------------|
| `/some/host/folder/mods` | `/home/starbound/openStarbound/mods` | Persistent mods (required). This at least needs to contain `packed.pak` for the server to succesfully start |
| `/some/host/folder/storage` | `/home/starbound/openStarbound/storage` | Persistent game data, required if you need access to `starbound_server.config` |

---

## Ports

| Port | Protocol | Description |
|------|----------|-------------|
| `21025` | TCP | Starbound server port |

> The server listens on all interfaces (`0.0.0.0` for IPv4, `::` for IPv6). Expose the port in Docker or use host networking.

---

## Usage

### Docker CLI

```bash
docker run -d \
  --name starbound \
  -p 21025:21025 \
  -v /some/host/folder/mods:/home/starbound/openStarbound/mods \
  -v /some/host/folder/storage:/home/starbound/openStarbound/storage \
  -e PUID=1000 \
  -e PGID=1000 \
  magne4000/starbound:latest
````

### Docker Compose

```yaml
services:
  starbound:
    image: magne4000/starbound:latest
    container_name: starbound
    environment:
      - PUID=1000
      - PGID=1000
    volumes:
      - /some/host/folder/mods:/home/starbound/openStarbound/mods
      - /some/host/folder/storage:/home/starbound/openStarbound/storage
    ports:
      - "21025:21025"
```

> For IPv6 access, ensure Docker is configured with IPv6 enabled and use the mapped container IPv6 address.

---

## Updating

* The container automatically checks for new releases of OpenStarbound on startup
* Files in `openStarbound` are persistent, so updates won’t overwrite mods or saved worlds

---

## Building from source

```bash
git clone https://github.com/magne4000/starbound-docker.git
cd starbound-docker
docker build -t magne4000/starbound:latest .
```
