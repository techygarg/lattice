# Dev Skills

Helper skills for creating and maintaining Lattice itself.

| Skill | Purpose |
|-------|---------|
| **skill-align** | Audit and fix all docs to ensure alignment with current skill inventory |
| **skill-forge** | Create a new Lattice skill (atom, molecule, or refiner) following all conventions |
| **skill-review** | Deep behavioral audit of a skill from multiple personas |
| **skill-validate** | Validate a SKILL.md against tier conventions, catch structural errors |

**Typical flow**: `skill-forge` → `skill-validate` → `skill-review` → `skill-align`

Canonical source lives in `dev-skills/`. Both `.claude/skills/` and `.github/skills/` are symlinks pointing here so Claude Code and Copilot share a single source of truth.
