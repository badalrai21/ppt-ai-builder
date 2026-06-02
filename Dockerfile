FROM node:22-alpine

WORKDIR /app

# Install system dependencies
RUN apk add --no-cache openssl

# Copy package files
COPY package.json package-lock.json* pnpm-lock.yaml* ./

# Install dependencies
RUN npm ci --omit=dev

# Copy source
COPY . .

# Build
RUN npm run build

# Start
EXPOSE 3000
CMD ["node", ".output/server/index.mjs"]
