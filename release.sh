#!/usr/bin/env bash
set -euo pipefail

# Braw3 release helper
# - Keeps pubspec.yaml as the single source of truth
# - Bumps build (+N) or sets a new marketing version (MAJOR.MINOR.PATCH)
# - Builds an IPA and opens Xcode Organizer

PUB="pubspec.yaml"

get_marketing() { awk -F'[:+ ]' '/^version:/{print $2}' "$PUB"; }
get_build()     { awk -F'[+: ]' '/^version:/{print $3}' "$PUB"; }

set_version_build() {
  local ver="$1" ; local b="$2"
  awk -v v="$ver" -v n="$b" '
    BEGIN{done=0}
    /^version:/ { print "version: " v "+" n; done=1; next }
    { print }
    END{ if(!done) { print "ERROR: no version line in pubspec.yaml" > "/dev/stderr"; exit 1 } }
  ' "$PUB" > "$PUB.tmp"
  mv "$PUB.tmp" "$PUB"
}

bump_build() {
  local v b nb
  v="$(get_marketing)"
  b="$(get_build)"
  nb=$((b+1))
  set_version_build "$v" "$nb"
  echo "🔢 Bumped build: $v+$nb"
}

set_marketing() {
  local v="$1"
  [[ "$v" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || { echo "Bad version: $v (use MAJOR.MINOR.PATCH)"; exit 1; }
  set_version_build "$v" "1"
  echo "🏷  Set marketing version: $v+1"
}

build_ipa() {
  echo "🧹 Cleaning & fetching deps…"
  flutter clean >/dev/null
  flutter pub get >/dev/null
  echo "🏗  Building IPA (values from pubspec.yaml)…"
  flutter build ipa --release
  echo "📦 Opening Xcode Organizer…"
  open build/ios/archive
}

usage() {
  cat <<EOF
Usage:
  ./release.sh bump           # bump build (+N), build IPA, open Organizer
  ./release.sh set 1.1.0      # set marketing version to 1.1.0 (+1), build IPA, open Organizer
  ./release.sh build          # just build IPA with current pubspec version, open Organizer
  ./release.sh show           # print current version/build
EOF
}

case "${1:-}" in
  bump)
    bump_build
    build_ipa
    ;;
  set)
    shift || true
    [[ $# -eq 1 ]] || { usage; exit 1; }
    set_marketing "$1"
    build_ipa
    ;;
  build)
    build_ipa
    ;;
  show)
    echo "Current: $(get_marketing)+$(get_build)"
    ;;
  *)
    usage
    exit 1
    ;;
esac
