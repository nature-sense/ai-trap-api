# ai-trap-api

OpenAPI 3.1 specification for the ai-trap REST API, plus a Flutter/Dart client generator.

The API is implemented by all ai-trap firmware variants:
- [ai-trap-linux](https://github.com/nature-sense/ai-trap-linux) — Raspberry Pi 5, Luckfox Pico Zero
- [ai-trap-esp](https://github.com/nature-sense/ai-trap-esp) — ESP32-P4 (planned)

---

## Endpoints

Base URL: `http://{trap-hostname}:8080`

### Trap

| Method | Path | Description |
|--------|------|-------------|
| `GET` | `/api/trap` | Trap ID and location |

### Capture

| Method | Path | Description |
|--------|------|-------------|
| `GET` | `/api/capture` | Current detection state and active session ID |
| `POST` | `/api/capture` | Start or stop detection |

> The MJPEG stream (`:9000`) runs independently and is always on.

### Status

| Method | Path | Description |
|--------|------|-------------|
| `GET` | `/api/status` | Uptime, FPS, total detections/tracks, DB size, SSE client count |

### Crops

| Method | Path | Description |
|--------|------|-------------|
| `GET` | `/api/crops` | List all saved crop images with metadata |
| `GET` | `/api/crops/{path}` | Download a JPEG crop (e.g. `20260314_153042/insect_42.jpg`) |

Crop metadata includes: file path, size, track ID, confidence, timestamp (µs),
label, session ID, and optional environmental sensor readings (temperature,
humidity, pressure).

### Configuration

| Method | Path | Description |
|--------|------|-------------|
| `POST` | `/api/config/location` | Set GPS coordinates |
| `POST` | `/api/config/threshold` | Set detection confidence threshold (0–1) |

### Autofocus

| Method | Path | Description |
|--------|------|-------------|
| `POST` | `/api/af/trigger` | Trigger a one-shot autofocus cycle |

### Events

| Method | Path | Description |
|--------|------|-------------|
| `GET` | `/api/events` | Redirects to SSE stream on `:8081` (detection events, crop saves) |

### Sync

A stateless pull-sync workflow for companion apps and cloud gateways — no SSH or SCP required.

| Step | Method | Path | Description |
|------|--------|------|-------------|
| 1 | `POST` | `/api/sync/session` | Open a session, get count of pending crops |
| 2 | `GET` | `/api/sync/session/{id}` | Manifest of unsynced crops (paths + metadata) |
| 3 | `GET` | `/api/crops/{file}` | Download each file via the standard crop endpoint |
| 4 | `POST` | `/api/sync/ack` | Mark files as successfully received |
| 5 | `DELETE` | `/api/sync/session/{id}` | Close session, optionally delete synced files |

---

## Ports

| Port | Protocol | Description |
|------|----------|-------------|
| `8080` | HTTP | REST API (this spec) |
| `8081` | HTTP / SSE | Server-sent events |
| `9000` | HTTP / MJPEG | Live camera stream |

---

## Flutter client generation

Generates a Dart/Dio HTTP client from the spec into a Flutter project.

**Prerequisites:** `openapi-generator` — install with:
```bash
brew install openapi-generator      # macOS
```

**Usage** (run from the Flutter project root):
```bash
./api/generate_flutter.sh
```

This will:
1. Pull the latest spec via `git submodule update`
2. Generate a null-safe Dart/Dio client into `lib/api/`
3. Clean up generated `doc/`, `test/`, and `.openapi-generator/` directories

---

## Using as a submodule

```bash
git submodule add https://github.com/nature-sense/ai-trap-api.git api
git submodule update --init
```

After cloning a repo that includes this submodule:
```bash
git clone --recurse-submodules <repo-url>
# or
git submodule update --init
```
