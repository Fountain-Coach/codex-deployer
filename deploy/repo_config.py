REPOS = {
    "fountainai": "https://github.com/Fountain-Coach/swift-codex-openapi-kernel.git",
    "kong-codex": "https://github.com/fountain-coach/kong-codex.git",
    "typesense-codex": "https://github.com/fountain-coach/typesense-codex.git",
    "teatro": "https://github.com/Fountain-Coach/teatro.git",
}

# Order repositories to match the semantic layout documented in README.md and
# agent.md. This helps humans and Codex traverse the monorepo snapshot in the
# same order as the `/srv` directory on a server.
REPO_ORDER = [
    "fountainai",
    "kong-codex",
    "typesense-codex",
    "teatro",
]

# Mapping of legacy names to the canonical repository names.
ALIASES = {
    "fountainai": "swift-codex-openapi-kernel",
    "teatro": "teatro",
}
