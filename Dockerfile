FROM node:20-alpine AS base

ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"

RUN npm install --global corepack@latest

RUN corepack enable

COPY . /app
WORKDIR /app


FROM base AS prod-deps

RUN --mount=type=cache,id=pnpm,target=/pnpm/store pnpm install --prod --frozen-lockfile


FROM base AS build

RUN --mount=type=cache,id=pnpm,target=/pnpm/store pnpm install --frozen-lockfile
RUN pnpm run build


FROM alpine

RUN apk --no-cache add thttpd perl

COPY --from=build /app/dist /var/www/http
COPY ./scripts/entrypoint.sh /entrypoint.sh

EXPOSE 80

RUN chmod +x /entrypoint.sh

ENTRYPOINT ["./entrypoint.sh","/var/www/http","/usr/sbin/thttpd","-D","-l","/dev/stderr","-d","/var/www/http"]
