# function-caller server container
FROM swift:6.1-jammy AS build
WORKDIR /src
COPY . .
RUN swift build -c release --product function-caller-server

FROM ubuntu:22.04
COPY --from=build /src/.build/release/function-caller-server /server
CMD ["/server"]

© 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
