# Running codex-deployer locally on macOS with Docker

This tutorial demonstrates how to start the deployment loop on a Mac using Docker Desktop. It mirrors the expected `/srv/deploy` layout without installing dependencies directly on your host.

## Prerequisites

- macOS with [Docker Desktop](https://www.docker.com/products/docker-desktop/) installed
- Git command line tools
- Review [environment_variables.md](environment_variables.md) and
  [managing_environment_variables.md](managing_environment_variables.md)
  for required variables like `GITHUB_TOKEN`.

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
FROM swift:5.8
RUN apt-get update && apt-get install -y git python3 python3-pip
WORKDIR /srv/deploy
COPY . /srv/deploy
DOCKER

docker build -t codex-deployer-local .
```

The image copies the repository into `/srv/deploy` so the dispatcher can run as it would on a server.

## 3. Start the dispatcher

Launch the container and run `dispatcher_v2.py`:

```bash
export GITHUB_TOKEN=yourtoken
export OPENAI_API_KEY=yourapikey  # optional
export GIT_USER_NAME="Codex Bot"
export GIT_USER_EMAIL=codex@example.com
docker run --rm -it -v $(pwd):/srv/deploy \
  -e GITHUB_TOKEN -e OPENAI_API_KEY -e GIT_USER_NAME -e GIT_USER_EMAIL \
  codex-deployer-local \
  python3 /srv/deploy/deploy/dispatcher_v2.py
```

`GITHUB_TOKEN` must be a personal access token with access to your private
repositories. See [managing_environment_variables.md](managing_environment_variables.md)
for instructions and links to GitHub's token documentation.

The first run will clone the other repositories defined in `repo_config.py` and write logs under `/srv/deploy/logs` inside the container.

## 4. Inspect logs

Build logs appear under `deploy/logs/` in your repository directory. Because the directory is mounted, you can view them on your host machine:

```bash
ls deploy/logs
cat deploy/logs/build.log
```

## 5. Stopping

Press `Ctrl-C` in the terminal running the container to stop the dispatcher.

## Tips

- Map additional volumes if you want the cloned service repositories (like `fountainai`) to persist outside the container.
- Edit files on your host; the container sees changes immediately because the project directory is mounted.

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
