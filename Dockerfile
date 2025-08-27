# Multi-stage build for semantic-browser-server
FROM swift:6.0-jammy AS build
WORKDIR /app
COPY . .
RUN swift build -c release --product semantic-browser-server

FROM swift:6.0-jammy-slim AS runtime
WORKDIR /run
COPY --from=build /app/.build/release/semantic-browser-server /usr/local/bin/semantic-browser-server
EXPOSE 8006
ENV SB_RATE_LIMIT=120
ENV SB_NET_BODY_MAX_COUNT=20
ENV SB_NET_BODY_MAX_BYTES=16384
ENV SB_NET_BODY_TOTAL_MAX_BYTES=131072
# Optional MIME allowlist for CDP body capture
# ENV SB_NET_BODY_MIME_ALLOW=text/markdown,application/xml
CMD ["semantic-browser-server"]
