# Running codex-deployer locally on macOS with Docker

This tutorial demonstrates how to start the deployment loop on a Mac using Docker Desktop. It mirrors the expected `/srv/deploy` layout without installing dependencies directly on your host.
For an overview of how the dispatcher adapts to macOS and Linux see the [handbook introduction](handbook/introduction.md#managing-platform-diversity).

## Prerequisites

- macOS with [Docker Desktop](https://www.docker.com/products/docker-desktop/) installed
- Git command line tools
- Review [environment_variables.md](environment_variables.md) and
  [managing_environment_variables.md](managing_environment_variables.md)
  for required variables like `GITHUB_TOKEN`.
- For integration testing workflow see [mac_local_testing.md](mac_local_testing.md).
## 1. Clone the repository

Open Terminal and clone the repository somewhere on your machine:

```bash
git clone https://github.com/fountain-coach/codex-deployer.git
cd codex-deployer
```

## 2. Build the Docker image

Create a small Docker image that includes Python, Git and Swift:

```bash
cat > Dockerfile <<'DOCKER'
FROM swift:6.1.2-jammy
RUN apt-get update && apt-get install -y git python3 python3-pip \
    && rm -rf /var/lib/apt/lists/*
WORKDIR /srv/deploy
COPY . /srv/deploy
DOCKER

docker build -t codex-deployer-local .
```

The image copies the repository into `/srv/deploy` so the dispatcher can run as it would on a server.

## 3. Start the dispatcher


Launch the container and run `dispatcher_v2.py` using the values from `dispatcher.env`:

```bash
export $(grep -v '^#' dispatcher.env | xargs)
docker run --rm -it \
  -v $(pwd):/srv/deploy \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -e GITHUB_TOKEN -e OPENAI_API_KEY -e GIT_USER_NAME -e GIT_USER_EMAIL \
  codex-deployer-local \
  python3 /srv/deploy/deploy/dispatcher_v2.py
```

Set `DISPATCHER_RUN_E2E=1` to run `docker compose` integration tests. The image already includes the Docker CLI; mount `/var/run/docker.sock` so the container can talk to the host daemon. See [environment_variables.md](environment_variables.md) for variable descriptions.

For a walkthrough of creating `dispatcher.env` and generating a `GITHUB_TOKEN`, see [managing_environment_variables.md](managing_environment_variables.md).
The dispatcher starts immediately because all repositories are already present under `/srv/deploy/repos`. After initialization you should see `Dispatcher started successfully` followed by a green circle.

## 4. Inspect logs

Build logs appear under `deploy/logs/` in your repository directory. Because the directory is mounted, you can view them on your host machine:

```bash
ls deploy/logs
cat deploy/logs/build.log
```

## 5. Stopping

Press `Ctrl-C` in the terminal running the container to stop the dispatcher.

## Tips
For a more detailed workflow including local integration tests, see [mac_local_testing.md](mac_local_testing.md).


- Map additional volumes if you want the cloned service repositories (like `fountainai`) to persist outside the container.
- Edit files on your host; the container sees changes immediately because the project directory is mounted.
- On macOS ensure the repository directory is listed under Docker Desktop > Settings > Resources > File Sharing, otherwise integration tests fail with "mounts denied" errors.

## 6. Cross-platform compilation

Version 2.4 of the dispatcher detects when it is running on macOS and invokes

`xcrun swift` so that the Apple SDKs are available. On Linux or other
environments the open source `swift` toolchain is used. You can experiment with
cross compiling by mounting additional volumes that contain the target SDKs and
passing environment variables such as `SDKROOT` to the container:

```bash
docker run --rm -it \
  -v $(xcode-select -p)/Platforms/MacOSX.platform/Developer/SDKs:/AppleSDKs \
  -e SDKROOT=/AppleSDKs/MacOSX.sdk \
  -v $(pwd):/srv/deploy codex-deployer-local \
  python3 /srv/deploy/deploy/dispatcher_v2.py
```

This lets the dispatcher build Swift packages that rely on Apple-provided
frameworks while still running inside a container. Prefer the open source Swift
toolchain whenever possible, but branch out into vendor-specific builds only
when necessary.


````text
©\ 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
````

