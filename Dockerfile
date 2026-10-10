# syntax=docker/dockerfile:1

FROM node:22-alpine AS build
WORKDIR /src
COPY package.json package-lock.json ./
RUN --mount=type=cache,target=/root/.npm npm ci
COPY . .
RUN npm run build

FROM nginxinc/nginx-unprivileged:1.29-alpine
LABEL org.opencontainers.image.source="https://github.com/krolbot/underfloor-heating-designer" \
      org.opencontainers.image.description="Containerized Underfloor Heating Designer" \
      org.opencontainers.image.licenses="Apache-2.0"
COPY nginx.conf /etc/nginx/nginx.conf
COPY --from=build /src/dist/ /usr/share/nginx/html/
EXPOSE 8080
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget -q -O /dev/null http://127.0.0.1:8080/app/ || exit 1
