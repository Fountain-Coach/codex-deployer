# persist server container
FROM swift:6.1-jammy AS build
WORKDIR /src
COPY . .
RUN swift build -c release --product persist-server

FROM ubuntu:22.04
COPY --from=build /src/.build/release/persist-server /server
CMD ["/server"]
