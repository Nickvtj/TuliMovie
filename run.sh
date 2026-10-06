#!/usr/bin/env bash
# TuliMovie — Chrome com TMDB (lê dart_defines.json)
set -euo pipefail
cd "$(dirname "$0")"

if [[ ! -f dart_defines.json ]]; then
  echo ""
  echo "dart_defines.json não encontrado."
  echo "  cp dart_defines.example.json dart_defines.json"
  echo "  # edite TMDB_API_KEY (v3) em https://www.themoviedb.org/settings/api"
  echo ""
  exit 1
fi

export PATH="/c/flutter/bin:$PATH"
flutter run -d chrome --dart-define-from-file=dart_defines.json
