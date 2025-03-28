#!/bin/sh
set -e

# Run database migrations
bunx prisma generate
bunx prisma migrate deploy

# Start the application
exec bun run src/index.ts