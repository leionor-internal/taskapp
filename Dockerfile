# -----------------------------
# Stage 1 - Build
# -----------------------------
FROM node:20-alpine AS builder

WORKDIR /app

COPY package*.json ./

# Cache npm packages
RUN --mount=type=cache,target=/root/.npm npm install

COPY . .

RUN npm prune --omit=dev

# -----------------------------
# Stage 2
# -----------------------------
FROM node:20-alpine

WORKDIR /app

RUN addgroup -S appgroup && adduser -S appuser -G appgroup

COPY --from=builder /app .

RUN chown -R appuser:appgroup /app

USER appuser

EXPOSE 3000

ENV NODE_ENV=production
ENV PORT=3000

CMD ["npm","start"]
