# -----------------------------
# Stage 1 - Build
# -----------------------------
FROM node:20-alpine AS builder

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install all dependencies
RUN npm install

# Copy application source
COPY . .

# If your application has a build step, uncomment:
# RUN npm run build

# Remove development dependencies
RUN npm prune --omit=dev

# -----------------------------
# Stage 2 - Production
# -----------------------------
FROM node:20-alpine

WORKDIR /app

# Create a non-root user
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Copy production files
COPY --from=builder /app .

# Change ownership
RUN chown -R appuser:appgroup /app

USER appuser

EXPOSE 3000

ENV NODE_ENV=production
ENV PORT=3000

CMD ["npm", "start"]
