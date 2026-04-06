# Custom Architecture Enforcement Rules

These are the enforcement instructions for custom architecture mode. They guide the AI on how to read and apply a team-defined architecture document when `architecture_mode: custom` is set. Unlike clean architecture mode, there are no embedded defaults — the team's document is the sole standard.

## Reading the Team's Document

The team's architecture document (at `paths.architecture`) is your sole reference for architectural rules. Read it completely before generating or reviewing any code.

Look for these key sections in the document:

1. **Layer Definitions** — what layers exist, what belongs in each, typical directory mapping
2. **Dependency Rules** — which layers can depend on which, the dependency direction
3. **Boundary Rules** — how layers communicate, DI patterns, data crossing formats
4. **Per-Layer Rules** — what is allowed and forbidden in each layer
5. **Key Flows** — representative data flows through the architecture (e.g., write operations, read operations)
6. **Validation Checklist** — numbered checks to run after generating code
7. **Anti-Patterns** — checkbox patterns to scan for and fix
8. **Ambiguity Signals** (optional) — gray areas where the AI should present options instead of silently choosing

If the document has additional sections beyond §8, read and apply them as additional architectural guidance.

## Self-Validation Checklist

STOP after generating each component. Read the **Validation Checklist** section (§6) from the loaded architecture document. Walk through each numbered item sequentially and verify ALL of them before proceeding. If any check clearly fails, fix the code before presenting it. If a check is a judgment call (see Ambiguity Signals), flag it — present your options and reasoning rather than silently choosing.

If the loaded document has no Validation Checklist section, surface a warning:

> "Your architecture document is missing a Validation Checklist section. Without it, the architecture atom cannot run style-specific post-generation verification. The 4 universal structural checks (layer placement, dependency direction, boundary data, single layer) still apply. Consider re-running `/architecture-refiner` to add a Validation Checklist."

Continue with the universal checks from the SKILL.md — partial enforcement is better than no enforcement.

## Active Anti-Pattern Scan

After verifying the checklist, read the **Anti-Patterns** section (§7) from the loaded architecture document. Scan your output for each listed anti-pattern. If you find any, fix them before presenting the code.

If the loaded document has no Anti-Patterns section, surface a warning:

> "Your architecture document is missing an Anti-Patterns section. Without it, the architecture atom cannot scan for style-specific anti-patterns. Consider re-running `/architecture-refiner` to add an Anti-Patterns section."

## Ambiguity Signals

If the loaded document has an **Ambiguity Signals** section (§8), read it before generating code. When you encounter one of the described scenarios during generation, present the options and your reasoning using `framework:collaborative-judgment` rather than silently choosing.

If the loaded document has no Ambiguity Signals section, use your judgment — when a component could reasonably live in two different layers per the document's rules, or a flow could follow multiple valid patterns, surface it as a judgment call.

## Applying the Architecture

Use the loaded document's definitions to enforce structural rules:

- **Layer placement**: Verify each class or module is in the correct layer as defined by the document's Layer Definitions section
- **Dependency direction**: Verify all source code dependencies follow the direction rules in the document's Dependency Rules section
- **Boundary rules**: Verify data crossing layer boundaries follows the patterns in the document's Boundary Rules section
- **Per-layer rules**: Verify each layer's allowed and forbidden patterns match the document's Per-Layer Rules section
- **Flow validation**: When the document describes architectural flows (Key Flows section), use them as the reference for validating generated code structure

When applying these rules, treat the document's definitions as authoritative — they represent the team's architectural decisions and take the same enforcement weight as clean architecture's built-in rules.
