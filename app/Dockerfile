# Stage 1: Build the application
FROM node:24-alpine AS builder

WORKDIR /app

# Copy package files and install dependencies
COPY package*.json ./
RUN npm ci

# Copy the rest of the application code
COPY . .

# Build the SvelteKit application
RUN npm run build

# Remove development dependencies
RUN npm prune --production

# Stage 2: Create the production image
FROM node:24-alpine

WORKDIR /app

# Copy built assets and production node_modules from builder
COPY --from=builder /app/build ./build
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package.json ./

# Expose the port the app runs on
ENV PORT=3000
ENV REDIS_URL="redis://localhost:6379"
EXPOSE 3000

# Start the application
CMD ["node", "build"]
