#!/usr/bin/env bash
set -euo pipefail

WATCH_DIR="/watch"
LIB_DIR="/library"
MAP_FILE="/app/kindle_map.csv"
LOG_FILE="/logs/kindle-sender.log"

SMTP_HOST="${SMTP_HOST:?}"
SMTP_PORT="${SMTP_PORT:-587}"
SMTP_USER="${SMTP_USER:?}"
SMTP_PASS="${SMTP_PASS:?}"
SMTP_FROM="${SMTP_FROM:?}"

shopt -s nocasematch

lookup_recipients() {
  filename="$1"
  while IFS=, read -r pattern recipients; do
    [[ -z "$pattern" ]] && continue
    [[ "$pattern" =~ ^# ]] && continue
    if [[ "$filename" =~ $pattern ]]; then
      echo "$recipients"
      return 0
    fi
  done < "$MAP_FILE"
  echo ""
}

send_to_kindle() {
  file="$1"
  recipients_csv="$2"
  IFS=';' read -ra RECIPS <<< "$recipients_csv"
  for r in "${RECIPS[@]}"; do
    r_trim="$(echo "$r" | xargs)"
    [[ -z "$r_trim" ]] && continue
    calibre-smtp --attachment "$file" \
      --relay "$SMTP_HOST" --port "$SMTP_PORT" \
      --username "$SMTP_USER" --password "$SMTP_PASS" \
      "$SMTP_FROM" "$r_trim" "Your ebook" "" >> "$LOG_FILE" 2>&1
  done
}

process_file() {
  in="$1"
  base="$(basename "$in")"
  ext="${base##*.}"
  out="$in"
  if [[ ! "$ext" =~ ^(epub|pdf)$ ]]; then
    out="${in%.*}.epub"
    ebook-convert "$in" "$out" >> "$LOG_FILE" 2>&1 || return 0
  fi
  calibredb add --with-library "$LIB_DIR" "$out" >> "$LOG_FILE" 2>&1 || true
  recips="$(lookup_recipients "$base")"
  if [[ -n "$recips" ]]; then
    send_to_kindle "$out" "$recips"
  fi
}

inotifywait -m -e close_write --format '%w%f' "$WATCH_DIR" | while read -r f; do
  sleep 2
  process_file "$f"
done
