# planner server container
FROM swift:6.1-jammy AS build
WORKDIR /src
COPY Generated/Server/Shared ./Shared
COPY Generated/Server/planner ./app
WORKDIR /src/app
RUN swiftc -emit-library -emit-module -module-name ServiceShared ../Shared/*.swift -o ../libServiceShared.so &&     swiftc -O -I .. -L .. -lServiceShared *.swift -o /server

FROM ubuntu:22.04
COPY --from=build /src/app/server /server
CMD ["/server"]
