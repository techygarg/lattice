# Custom Architecture Enforcement Rules

These are the enforcement instructions for custom architecture mode. They guide the AI to read and apply the team's architecture document when `architecture_mode: custom` is set. There are no embedded defaults -- the team's document is the sole standard.

## Reading the Team's Document

The team architecture document (at `paths.architecture`) is the sole reference for architecture rules. Read it completely before generating or reviewing code.

Look for these key sections in the document:

1. **Layer Definitions** — which layers exist, what belongs in each, typical directory mapping
2. **Dependency Rules** — which layers may depend on which, dependency direction
3. **Boundary Rules** — how layers communicate, DI patterns, data-crossing formats
4. **Per-Layer Rules** — allowed/forbidden patterns per layer
5. **Key Flows** — representative data flows through the architecture (e.g., write ops, read ops)
6. **Validation Checklist** — numbered checks run after generating code
7. **Anti-Patterns** — checkbox patterns to scan for and fix
8. **Ambiguity Signals** (optional) — gray areas where the AI presents options instead of silently choosing

If the document has additional sections beyond §8, read and apply them as additional architecture guidance.

## Self-Validation Checklist

**STOP after generating each component.** Read the **Validation Checklist** section (§6) from the loaded architecture document. Walk through each numbered item sequentially and verify ALL before proceeding. A check clearly fails → fix the code before presenting. A check is a judgment call (see Ambiguity Signals) → flag it -- present options and reasoning rather than silently choosing.

If the loaded document has no Validation Checklist section, surface this warning:

> "Your architecture document is missing a Validation Checklist section. Without it, the architecture atom cannot run style-specific post-generation verification. Consider re-running `/architecture-refiner` to add a Validation Checklist."

Then apply these baseline structural checks as fallback -- partial enforcement beats no enforcement:

1. **LAYER PLACEMENT**: Is each class/module in the correct layer per the loaded document?
2. **DEPENDENCY DIRECTION**: Do all source dependencies follow the direction rule in the loaded document?
3. **BOUNDARY DATA**: Does data crossing layers use the pattern described in the loaded document?
4. **SINGLE LAYER**: Does each class belong to exactly one layer? No class spans multiple concerns across layers.

All checks pass → state "Passes architecture. [next step]."

## Active Anti-Pattern Scan

After verifying the checklist, read the **Anti-Patterns** section (§7) from the loaded architecture document. Scan the output for each listed anti-pattern. Any found → fix before presenting the code.

If the loaded document has no Anti-Patterns section, surface this warning:

> "Your architecture document is missing an Anti-Patterns section. Without it, the architecture atom cannot scan for style-specific anti-patterns. Consider re-running `/architecture-refiner` to add an Anti-Patterns section."

## Ambiguity Signals

If the loaded document has an **Ambiguity Signals** section (§8), read it before generating code. When you encounter a described scenario during generation, present options and reasoning using `framework:collaborative-judgment` rather than silently choosing.

If the loaded document has no Ambiguity Signals section, use judgment -- when a component could reasonably live in two different layers per the document's rules, or a flow could follow multiple valid patterns, surface it as a judgment call.

## Applying the Architecture

Use the loaded document's definitions to enforce structural rules:

- **Layer placement**: verify each class/module sits in the correct layer as defined by the document's Layer Definitions section.
- **Dependency direction**: verify all source-code dependencies follow the direction rules in the document's Dependency Rules section.
- **Boundary rules**: verify data crossing layer boundaries follows the patterns in the document's Boundary Rules section.
- **Per-layer rules**: verify each layer's allowed/forbidden patterns match the document's Per-Layer Rules section.
- **Flow validation**: when the document describes architecture flows (Key Flows section), use them as the reference to validate generated code structure.

When applying these rules, treat the document's definitions as authoritative -- they represent the team's architecture decisions and carry the same enforcement weight as clean architecture's built-in rules.
