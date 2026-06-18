# Security Policy

## Supported Versions

Lattice is a skills library distributed as plain text files. There are no compiled binaries, runtime dependencies, or versioned release lines that receive security backports. The current `main` branch is the only supported version.

## Reporting a Vulnerability

If you discover a security issue in Lattice — including prompt injection patterns in skill files, malicious content in templates, or supply chain concerns with the distribution mechanism — please report it privately rather than opening a public issue.

**Report via GitHub's private vulnerability reporting:**
Go to [Security → Report a vulnerability](https://github.com/techygarg/lattice/security/advisories/new) on this repository.

Include:
- A description of the issue and its potential impact
- The affected file(s) or component(s)
- Steps to reproduce or a proof of concept where applicable

You will receive an acknowledgement within 72 hours. We aim to assess and respond to all reports within 7 days.

## Scope

The main security concern for a skills library is **prompt injection** — a malicious `SKILL.md` that overrides AI agent instructions when loaded. The CI pipeline scans for known injection patterns on every push and pull request.

Out of scope: general coding advice, feature requests, or issues with how AI models interpret skills.
