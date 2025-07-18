# Codex-Deployer Handbook

The handbook guides you through the Codex deployment loop from initial setup to
the inner workings of the dispatcher. Start with the basics, then move on to
service‑specific details and deeper background material.

## Table of Contents

- [Getting Started](#getting-started)
- [Dispatcher Details](#dispatcher-details)
- [Background Reading](#background-reading)

## Getting Started

The articles in this section show how to set up Codex-Deployer locally and run
basic tests. They also explain where to configure required environment
variables.

- [What is Git?](../what_is_git.md)
- [Running on macOS with Docker](../mac_docker_tutorial.md)
- [Local Testing on macOS](../mac_local_testing.md)
- [Managing Environment Variables](../managing_environment_variables.md)
- [Environment Variables Reference](../environment_variables.md)

## Dispatcher Details

This section covers the dispatcher service itself—how it loops through
repositories, builds services and interacts with GitHub pull requests.

- [Dispatcher v2 Overview](../dispatcher_v2.md)
- [Pull Request Workflow](../pull_request_workflow.md)

## Background Reading

These documents capture broader architectural decisions and optional tools that
inform how the deployment loop evolves over time.

- [Design Pattern Evaluation](../design_patterns.md)
- [Log Aggregation Setup](../log_aggregation.md)
- [Secrets API Proposal](../secrets_api_proposal.md)
- [FountainAI macOS UI Plan](../fountainai_mac_ui_plan.md)

## Getting Started

The articles in this section show how to set up Codex-Deployer locally and run
basic tests. They also explain where to configure required environment
variables.

- [Running on macOS with Docker](../mac_docker_tutorial.md)
- [Local Testing on macOS](../mac_local_testing.md)
- [Managing Environment Variables](../managing_environment_variables.md)
- [Environment Variables Reference](../environment_variables.md)

## Dispatcher Details

Here you’ll find specifics about the dispatcher service itself, including how
it interacts with GitHub pull requests.

- [Dispatcher v2 Overview](../dispatcher_v2.md)
- [Pull Request Workflow](../pull_request_workflow.md)

## Background Reading

These documents capture broader architectural decisions and additional tools
used around the deployment process.

- [Design Pattern Evaluation](../design_patterns.md)
- [Log Aggregation Setup](../log_aggregation.md)
- [Secrets API Proposal](../secrets_api_proposal.md)
- [What is Git?](../what_is_git.md)
- [FountainAI macOS UI Plan](../fountainai_mac_ui_plan.md)

These documents should give you a complete picture of how the dispatcher works,
how to configure it, and how the surrounding services fit together. All guides
reference [`environment_variables.md`](../environment_variables.md) when
describing required settings.

