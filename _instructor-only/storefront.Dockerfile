# Reference solution — Week 4 capstone. Build context is ../storefront.

# ---- build stage: compile the static site ----
FROM node:20-alpine AS build
WORKDIR /app
COPY package.json package-lock.json* ./
RUN npm ci
COPY tsconfig.json vite.config.ts vite-env.d.ts index.html ./
COPY src ./src
ARG VITE_API_BASE_URL=""
ENV VITE_API_BASE_URL=$VITE_API_BASE_URL
RUN npm run build

# ---- runtime stage: serve the static output, non-root ----
FROM nginx:1.27-alpine
COPY --from=build /app/dist /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf

RUN addgroup -S freshcart && adduser -S freshcart -G freshcart \
  && chown -R freshcart:freshcart /usr/share/nginx/html /var/cache/nginx /etc/nginx \
  && touch /var/run/nginx.pid && chown freshcart:freshcart /var/run/nginx.pid
USER freshcart

EXPOSE 8080
CMD ["nginx", "-g", "daemon off;"]
