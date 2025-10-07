# === Build stage ===
FROM node:20.9-alpine AS builder
WORKDIR /app

# Copy package files first for better cache
COPY package*.json ./

# Install all deps (dev + prod) to allow builds
RUN npm ci

# Copy source
COPY . .

# Optional build: only runs when you pass --build-arg BUILD=true and package.json has a build script
ARG BUILD=false
RUN if [ "$BUILD" = "true" ] && grep -q "\"build\"" package.json; then npm run build; fi

# Remove devDependencies to make the app production-ready in the layer we will copy
RUN npm prune --production

# === Production stage ===
FROM node:20.9-alpine AS production
WORKDIR /app

# Create non-root user
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Copy app (including pruned node_modules) from builder
COPY --from=builder /app /app

# Set env
ENV NODE_ENV=production
ENV PORT=3000

# Ensure correct permissions before switching user
RUN chown -R appuser:appgroup /app

# Switch to non-root user
USER appuser

# Expose port
EXPOSE 3000

# Use npm start (expects package.json "start": "node app.js")
CMD ["npm", "start"]
