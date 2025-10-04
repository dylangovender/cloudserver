# cloudserver

Infra as code for my self-hosted ebook stack.

## Services (added incrementally)
- Transmission (torrent client) via Docker Compose
- Prowlarr (indexer manager) — to be added
- Readarr (ebook automation) — to be added
- Calibre-Web (library UI) — to be added
- Caddy (TLS + auth proxy) — optional later
- Kindle Sender helper — optional later

## Layout
- `docker-compose.yml` — current services
- `.env.example` — copy to `.env` and fill in secrets
- `.gitignore` — keeps secrets and heavy data out of Git
- `cwa/`, `qbittorrent/`, `readarr/`, `kindle-sender/` — service dirs

## Quick start (Transmission only)
```bash
cp .env.example .env
# edit .env for TR_PASSWORD, TZ, etc.

docker compose up -d transmission
