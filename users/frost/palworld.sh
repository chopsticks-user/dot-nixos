#!/usr/bin/env bash
# palworld — run a Palworld dedicated server and playit.gg tunnel on demand.
# Usage: palworld {start|stop|run|status|logs|update}
#
# Layout:
#   $PALWORLD_DATA_DIR/Config/      server config (.ini files)
#   $PALWORLD_DATA_DIR/SaveGames/   world saves
#
# Paths come from the environment (home.nix sets them), with defaults
# so the script also works when run directly.

set -euo pipefail

server_dir="${PALWORLD_SERVER_DIR:-$HOME/.local/share/palworld}"
data_dir="${PALWORLD_DATA_DIR:-$HOME/projects/pal-server}"
state_dir="${PALWORLD_STATE_DIR:-$HOME/.local/state/palworld}"

config_dir="$data_dir/Config"
saves_dir="$data_dir/SaveGames"
server_bin="$server_dir/Pal/Binaries/Linux/PalServer-Linux-Shipping"
logfile="$state_dir/palworld.log"
playit_env="$HOME/.config/playit/env"
playit_image="ghcr.io/playit-cloud/playit-agent:latest"
args=(-port=8211 -players=16 -useperfthreads -NoAsyncLoadingThread -UseMultithreadForDS)

# Find the server by its actual binary, not a saved PID
is_running() {
  pgrep -f "$server_bin" >/dev/null
}

server_pids() {
  pgrep -f "$server_bin" | tr '\n' ' '
}

install() {
  steamcmd +force_install_dir "$server_dir" +login anonymous +app_update 2394010 validate +quit
}

# link_to <path inside the server> <your folder>
# Makes <path> a symlink to <your folder>. Fixes links that point elsewhere,
# and moves an existing real folder over instead of deleting it.
link_to() {
  path="$1"; target="$2"
  mkdir -p "$target" "$(dirname "$path")"
  if [ -L "$path" ]; then
    [ "$(readlink "$path")" = "$target" ] && return 0
    rm "$path"
  elif [ -d "$path" ]; then
    if [ -n "$(ls -A "$target")" ]; then
      echo "Both $path and $target have files; merge them by hand first" >&2
      exit 1
    fi
    rmdir "$target"
    mv "$path" "$target"
  fi
  ln -s "$target" "$path"
}

setup() {
  # The server needs steamclient.so in ~/.steam/sdk64
  src="$(find -L "$HOME/.steam" "$HOME/.local/share/Steam" -name steamclient.so \
           -path '*linux64*' -not -path '*sdk64*' 2>/dev/null | head -n1 || true)"
  if [ -z "$src" ]; then echo "steamclient.so not found" >&2; exit 1; fi
  mkdir -p "$HOME/.steam/sdk64"
  if [ ! "$src" -ef "$HOME/.steam/sdk64/steamclient.so" ]; then
    cp -f "$src" "$HOME/.steam/sdk64/"
  fi

  link_to "$server_dir/Pal/Saved/Config/LinuxServer" "$config_dir"
  link_to "$server_dir/Pal/Saved/SaveGames"          "$saves_dir"
}

prepare() {
  [ -x "$server_dir/PalServer.sh" ] || install
  setup
}

playit_start() {
  if [ ! -f "$playit_env" ]; then
    echo "Missing $playit_env (should contain SECRET_KEY=...)" >&2; exit 1
  fi
  podman container exists palworld-playit && return 0
  podman run -d --rm --name palworld-playit --network=host \
    --env-file "$playit_env" "$playit_image" >/dev/null
}

playit_stop() {
  podman stop palworld-playit >/dev/null 2>&1 || true
}

server_stop() {
  is_running || return 0
  pkill -TERM -f "$server_bin" || true
  for _ in $(seq 30); do is_running || return 0; sleep 1; done
  pkill -KILL -f "$server_bin" || true
}

case "${1:-}" in
  start)
    if is_running; then echo "Already running (pid $(server_pids))"; exit 0; fi
    prepare
    mkdir -p "$state_dir"
    setsid steam-run "$server_dir/PalServer.sh" "${args[@]}" >"$logfile" 2>&1 </dev/null &
    playit_start
    echo "Started server and playit tunnel. Logs: palworld logs"
    ;;
  run)
    # Foreground; Ctrl+C stops both the server and the tunnel
    if is_running; then echo "Already running in the background" >&2; exit 1; fi
    prepare
    playit_start
    trap 'playit_stop; server_stop' EXIT
    steam-run "$server_dir/PalServer.sh" "${args[@]}"
    ;;
  stop)
    playit_stop
    if ! is_running; then echo "Server not running"; exit 0; fi
    server_stop
    echo "Stopped server and tunnel"
    ;;
  status)
    if is_running; then echo "Server: running (pid $(server_pids))"; else echo "Server: stopped"; fi
    if podman container exists palworld-playit; then echo "Tunnel: running"; else echo "Tunnel: stopped"; fi
    ;;
  logs)
    tail -f "$logfile"
    ;;
  update)
    if is_running; then echo "Stop the server first: palworld stop" >&2; exit 1; fi
    install
    setup
    ;;
  *)
    echo "Usage: palworld {start|stop|run|status|logs|update}" >&2
    exit 1
    ;;
esac
