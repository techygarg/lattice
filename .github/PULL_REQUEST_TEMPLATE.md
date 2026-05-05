## What does this PR do?

<!-- One sentence. What changed and why. -->

## Type of change

- [ ] New atom
- [ ] New molecule
- [ ] New refiner
- [ ] Improvement to existing skill
- [ ] Documentation fix
- [ ] Other: ___

## Breaking change?

- [ ] Yes — this modifies an existing skill's section structure, removes a check, or changes behavior that existing users depend on
- [ ] No

## Skill checklist

_Complete the relevant section. Delete sections that don't apply._

### New or modified atom
- [ ] Frontmatter: `name` is lowercase kebab-case and matches the folder name
- [ ] Frontmatter: `description` includes specific trigger phrases (not just "applies best practices")
- [ ] Section order: Config Resolution → Self-Validation Checklist → Active Anti-Pattern Scan → principle content
- [ ] Self-Validation Checklist uses numbered items with STOP language and **BOLD LABEL** format
- [ ] Active Anti-Pattern Scan uses `- [ ] Pattern:` checkbox format
- [ ] `references/defaults.md` exists (code-quality atoms) or is intentionally absent (special atoms)
- [ ] Ambiguity Signals section present (code-quality atoms only)
- [ ] Enforces exactly one principle — not bundled concerns

### New or modified molecule
- [ ] `## Required Skills` uses `framework:{atom-name}` prefix (not `lattice:`)
- [ ] Each required skill has a note on when it applies (always / conditional)
- [ ] Workflow steps are numbered and reference atoms by name
- [ ] No atom content is copied inline — atoms are referenced and applied, not duplicated
- [ ] Each step has a clear purpose in the workflow sequence

### New or modified refiner
- [ ] `assets/template.md` exists with `<!-- INTERVIEW GUIDANCE: -->` comments
- [ ] Template has YAML frontmatter declaring `mode: overlay` or `mode: override`
- [ ] Interview questions are grouped logically and asked one group at a time
- [ ] Output section specifies the `.lattice/standards/` file produced

## Testing

**Tool used:** <!-- Claude Code / Cursor -->
**Model:** <!-- e.g. Claude Sonnet 4.6, Opus 4.7 -->
**Invoked against:** <!-- e.g. sample/ User Service spec, a real Go REST API project -->
**What worked correctly:** <!-- Skill enforced X, caught Y violation, flagged Z as a judgment call -->
**Edge cases tested:** <!-- No .lattice/config.yaml present, override mode, conditional atom trigger -->

## Documentation

- [ ] Updated `docs/how-it-works.md` skill inventory table (if adding a new skill)
- [ ] No documentation changes needed

## Anything else?

<!-- Context that would help the reviewer — design decisions, alternatives considered, known gaps. -->
