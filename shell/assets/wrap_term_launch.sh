#!/usr/bin/env sh

cat ~/.local/state/webb/sequences.txt 2>/dev/null

exec "$@"
