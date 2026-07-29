# Reference solution — Week 4 capstone. Build context is ../checkout-api.

# ---- build stage: compile TypeScript ----
FROM node:20-alpine AS build
WORKDIR /app
COPY package.json package-lock.json* ./
RUN npm ci
COPY tsconfig.json ./
COPY src ./src
RUN npm run build

# ---- runtime stage: only what's needed to run ----
FROM node:20-alpine
WORKDIR /app
ENV NODE_ENV=production
COPY package.json package-lock.json* ./
RUN npm ci --omit=dev
COPY --from=build /app/dist ./dist

RUN addgroup -S freshcart && adduser -S freshcart -G freshcart
USER freshcart

EXPOSE 3000
CMD ["node", "dist/index.js"]
