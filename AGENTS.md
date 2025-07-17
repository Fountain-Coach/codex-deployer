# Agent Guidance

- Keep `docs/environment_variables.md` updated whenever new environment variables are introduced or removed.
- Reference `docs/environment_variables.md` in documentation and code comments when explaining configuration.

## Cross-Platform Build and Test Workflow
1. Use Docker (Ubuntu Jammy with Swift 6.1) together with `.env` and `docker-compose.yml` to build each service. Run `swift build -c release --product <service-name>` from `/src`.
2. Halt the cycle and log any compiler errors to `logs/build-<timestamp>.log`.
3. After a successful build, run `swift test` for all modules (e.g. `ParserTests`, `ModelEmitterTests`, `ServicesIntegrationTests`). Parse the output and fail the cycle if any `XCTAssert` or decoding errors appear.
4. Optionally mirror the tests locally on macOS for debugging, but do not rely on that result for commits.
5. Only commit and push if Linux build and tests pass and `dispatcher.py` confirms success. Use the message `Update build log build-<timestamp>.log: <UTC timestamp>` and push with token-auth remotes. If the push fails due to an upstream update, `git pull --rebase`, recommit and retry.
6. Persist build logs in `logs/build-<timestamp>.log` and include structured failure data in JSON when applicable.
