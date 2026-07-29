# Instructor-only: Week 4 reference solution

This folder is a working answer key for the Week 4 capstone (multi-stage Dockerfiles + Docker Compose) — **do not share this with students** before their submissions are due. Keep it out of whatever repo/branch they clone, or on a private branch of this one.

It exists so you have something to grade against and to demo live if needed — the exact same requirements as the published Week 4 content pack: multi-stage builds, non-root users, correct layer ordering, a shared network, and a named volume for Postgres data.

## Running it

From this folder:

```
docker compose up --build
```

- Storefront: http://localhost:8080
- Checkout API directly: http://localhost:3000/api/products
- Postgres: localhost:5432 (user/pass/db: `freshcart`/`freshcart`/`freshcart`)

To prove the volume survives a container restart (the Week 4 stretch goal): `docker compose kill postgres && docker compose up -d postgres`, then confirm `/api/products` still returns the seeded data.

## What each file does

- `checkout-api.Dockerfile` — build stage compiles TypeScript, runtime stage installs only production dependencies and runs as a non-root user.
- `storefront.Dockerfile` — build stage runs the Vite build, runtime stage serves the static output from `nginx:alpine` as a non-root user, listening on 8080 (not 80, to avoid needing root).
- `nginx.conf` — the storefront's nginx proxies `/api/*` to the `checkout-api` container by service name — this is a deliberate small preview of the load balancer's job in Week 5.
- `docker-compose.yml` — wires all three containers together on one bridge network, mounts `checkout-api/db/init.sql` into Postgres's official init directory, and stores Postgres data in a named volume.
