# Agent Instructions

This repository is a Jekyll static website containerized with Docker.

## How to Build and Run

To build and start the application:

```bash
docker compose up -d --build
```

*(Note: Use `sudo docker compose ...` if your user is not in the `docker` group).*

To view logs:
```bash
docker compose logs -f
```

To stop the application:
```bash
docker compose down
```

## How to Verify

1. Ensure the container is healthy and responding with HTTP 200:
   ```bash
   curl -sI http://localhost:4000
   ```
2. Verification URLs:
   - **Local Machine**: `http://localhost:4000` (LiveReload: `http://localhost:35729`)
   - **LAN Network**: `http://192.168.1.152:4000`
