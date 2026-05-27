FROM node:23.9.0-alpine AS builder
WORKDIR /app

COPY yarn.lock package.json ./

RUN yarn install

COPY . .

RUN yarn build

FROM node:23.9.0-alpine AS deployer

WORKDIR /app

COPY --from=builder /app/build build/
COPY --from=builder /app/package.json .
COPY --from=builder /app/.env .

EXPOSE 3000

ENV NODE_ENV=production

CMD [ "node", "build" ]
