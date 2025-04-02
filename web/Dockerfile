FROM oven/bun:1.1.18 as build

WORKDIR /app

# Copy only package files first to leverage caching
COPY package.json ./

# Install dependencies without running prepare script first
RUN bun install --no-prepare

# Copy the rest of the application
COPY . .

# Now run prepare separately with specific version constraints
ENV NODE_OPTIONS="--no-warnings"
RUN bun nuxt prepare

# Build the application
RUN bun run build

# Production stage
FROM oven/bun:1.1.18-slim

WORKDIR /app

# Copy only necessary files from build stage
COPY --from=build /app/.output ./.output
COPY --from=build /app/package.json ./package.json

# Expose the port
EXPOSE 3000

# Set environment variables
ENV NODE_ENV=production

# Start the application
CMD ["bun", ".output/server/index.mjs"]