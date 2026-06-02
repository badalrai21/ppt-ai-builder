# Build stage
FROM node:22-alpine AS builder

WORKDIR /app

# Install system dependencies
RUN apk add --no-cache openssl

# Copy package files
COPY package.json package-lock.json* pnpm-lock.yaml* ./

# Install all dependencies (including dev)
RUN npm ci --legacy-peer-deps

# Copy source
COPY . .

# Build
RUN npm run build

# Production stage
FROM node:22-alpine

WORKDIR /app

# Install only runtime dependencies
RUN apk add --no-cache openssl

# Copy package files
COPY package.json package-lock.json* pnpm-lock.yaml* ./

# Install production dependencies only
RUN npm ci --omit=dev --legacy-peer-deps

# Copy built output from builder
COPY --from=builder /app/.output ./.output

# Start
EXPOSE 3000
CMD ["node", ".output/server/index.mjs"]
