FROM node:22-alpine AS builder
WORKDIR /app

COPY package-lock.json package.json ./
RUN npm ci

COPY . .
RUN npm run build

FROM node:22-alpine AS runner
WORKDIR /app

COPY --from=builder /app/build build/
COPY --from=builder /app/package.json .
COPY --from=builder /app/package-lock.json .
RUN npm ci --omit=dev

EXPOSE 3000
ENV NODE_ENV=production

# DB connection passed at runtime:
# docker run -e DB_HOST=... -e DB_USER=... -e DB_PASSWORD=... -e DB_PORT=3306
CMD ["node", "build"]
