# Modernization Backlog (Post-C2)

This backlog captures the next modernization wave after completing the ranked corrective roadmap (M1-C2).

## Objectives

- Reduce legacy coupling in MATLAB orchestration and data flow.
- Improve path and module readability across solver, tests, scripts, and docs.
- Keep changes PR-sized and reversible.

## Ranked PR-Sized Tasks

### MZ1. Publish explicit module contracts

- [x] Add contract notes for each public MATLAB entry point in `src/matlab`.
- [x] Define owner boundaries for problem definition, assembly, solve, error summary, and plotting.
- [x] Add a quick dependency map in `docs/ARCHITECTURE_MAP.md`.

Status:
- Complete. Public entry contracts are documented in `docs/MODULE_CONTRACTS.md`, and the architecture file now includes a quick dependency map.

Acceptance criteria:
- Public entry points and ownership boundaries are documented in one place.
- New contributors can identify where to modify behavior without tracing the full codebase.

### MZ2. Normalize path conventions in automation

- [x] Standardize script/task commands to avoid hard-coded workspace-specific paths.
- [x] Prefer relative repository paths and temp output for generated artifacts.
- [x] Keep generated logs out of tracked docs.

Status:
- Complete. Profiling commands now run from repository root without hard-coded absolute paths, and generated profiler output is routed to temp locations.

Acceptance criteria:
- Build, test, benchmark, and profiling commands run from repository root without path edits.
- Generated artifacts are either ignored or written to temp locations.

### MZ3. Strengthen documentation information architecture

- [x] Keep top-level `README.md` strictly operational.
- [x] Keep `docs/README.md` as canonical navigation to plans, evidence, and report materials.
- [x] Ensure roadmap, status, and backlog files do not duplicate conflicting state.

Status:
- Complete. Top-level README now points to a single docs index, and docs README is the canonical navigation page for plans, architecture, and evidence.

Acceptance criteria:
- A first-time reader can navigate run/test/report/performance/plan docs in less than 2 minutes.
- No duplicated or contradictory status claims across plan files.

### MZ4. Add modernization quality checks

- [x] Add lightweight CI checks for stale references and broken internal markdown links.
- [x] Add a doc-consistency check for required plan/status/backlog markers.

Status:
- Complete. CI now runs `scripts/check_docs_quality.ps1` on push and pull requests to detect broken markdown links, hard-coded local repo paths, and missing required documentation markers.

Acceptance criteria:
- Pull requests fail early when internal docs drift or links break.
- Plan/status files keep required sections and remain synchronized.

### MZ5. Introduce a stable compute API surface

- Define a stable, test-focused compute API layer independent of plotting/UI concerns.
- Formalize output schemas used by tests, benchmarks, and report data generation.

Acceptance criteria:
- Regression and benchmark consumers rely on stable documented output fields.
- Refactors behind the API do not require broad downstream updates.

## Execution Guidance

- One branch and one PR per modernization task.
- Documentation-only tasks can skip MATLAB execution unless command examples change.
- Behavior-changing tasks must run the guarded MATLAB suite before merge.
