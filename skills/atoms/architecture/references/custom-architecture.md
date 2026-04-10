# Custom Architecture Enforcement Rules

Enforcement instructions for custom architecture mode. Guide AI read/apply team architecture doc when `architecture_mode: custom` set. No embedded defaults — team doc = sole standard.

## Reading the Team's Document

Team architecture doc (at `paths.architecture`) = sole reference for arch rules. Read completely before gen/review code.

Look for key sections in doc:

1. **Layer Definitions** — layers exist, what belong each, typical dir mapping
2. **Dependency Rules** — which layers depend which, dependency direction
3. **Boundary Rules** — how layers communicate, DI patterns, data crossing formats
4. **Per-Layer Rules** — allowed/forbidden each layer
5. **Key Flows** — representative data flows through arch (e.g., write ops, read ops)
6. **Validation Checklist** — numbered checks run after gen code
7. **Anti-Patterns** — checkbox patterns scan/fix
8. **Ambiguity Signals** (optional) — gray areas where AI present options instead silent choose

If doc have additional sections beyond §8, read/apply as additional arch guidance.

## Self-Validation Checklist

STOP after gen each component. Read **Validation Checklist** section (§6) from loaded arch doc. Walk through each numbered item sequentially, verify ALL before proceed. If any check clearly fail, fix code before present. If check = judgment call (see Ambiguity Signals), flag it — present options/reasoning rather than silent choose.

If loaded doc have no Validation Checklist section, surface warning:

> "Your architecture document is missing a Validation Checklist section. Without it, the architecture atom cannot run style-specific post-generation verification. The 4 universal structural checks (layer placement, dependency direction, boundary data, single layer) still apply. Consider re-running `/architecture-refiner` to add a Validation Checklist."

Continue with universal checks from SKILL.md — partial enforcement better than no enforcement.

## Active Anti-Pattern Scan

After verify checklist, read **Anti-Patterns** section (§7) from loaded arch doc. Scan output for each listed anti-pattern. If find any, fix before present code.

If loaded doc have no Anti-Patterns section, surface warning:

> "Your architecture document is missing an Anti-Patterns section. Without it, the architecture atom cannot scan for style-specific anti-patterns. Consider re-running `/architecture-refiner` to add an Anti-Patterns section."

## Ambiguity Signals

If loaded doc have **Ambiguity Signals** section (§8), read before gen code. When encounter described scenario during gen, present options/reasoning using `framework:collaborative-judgment` rather than silent choose.

If loaded doc have no Ambiguity Signals section, use judgment — when component could reasonably live two different layers per doc rules, or flow could follow multiple valid patterns, surface as judgment call.

## Applying the Architecture

Use loaded doc definitions enforce structural rules:

- **Layer placement**: Verify each class/module in correct layer as defined by doc Layer Definitions section
- **Dependency direction**: Verify all source code dependencies follow direction rules in doc Dependency Rules section
- **Boundary rules**: Verify data crossing layer boundaries follow patterns in doc Boundary Rules section
- **Per-layer rules**: Verify each layer allowed/forbidden patterns match doc Per-Layer Rules section
- **Flow validation**: When doc describe arch flows (Key Flows section), use as reference validate gen code structure

When apply rules, treat doc definitions as authoritative — represent team arch decisions, take same enforcement weight as clean architecture built-in rules.