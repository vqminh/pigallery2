#!/usr/bin/env bash
set -e

cd "$(dirname "$0")"

echo "Building TypeScript..."
npx tsc --project tsconfig.json

echo "Starting server..."
exec node ./src/backend/index
