# Modernization Backlog (Post-C2)

This backlog captures the next modernization wave after completing the ranked corrective roadmap (M1-C2).

## Objectives

- Reduce legacy coupling in MATLAB orchestration and data flow.
- Improve path and module readability across solver, tests, scripts, and docs.
- Keep changes PR-sized and reversible.

## Ranked PR-Sized Tasks

### MZ1. Publish explicit module contracts

- Add contract notes for each public MATLAB entry point in `src/matlab`.
- Define owner boundaries for problem definition, assembly, solve, error summary, and plotting.
- Add a quick dependency map in `docs/ARCHITECTURE_MAP.md`.

Acceptance criteria:
- Public entry points and ownership boundaries are documented in one place.
- New contributors can identify where to modify behavior without tracing the full codebase.

### MZ2. Normalize path conventions in automation

- Standardize script/task commands to avoid hard-coded workspace-specific paths.
- Prefer relative repository paths and temp output for generated artifacts.
- Keep generated logs out of tracked docs.

Acceptance criteria:
- Build, test, benchmark, and profiling commands run from repository root without path edits.
- Generated artifacts are either ignored or written to temp locations.

### MZ3. Strengthen documentation information architecture

- Keep top-level `README.md` strictly operational.
- Keep `docs/README.md` as canonical navigation to plans, evidence, and report materials.
- Ensure roadmap, status, and backlog files do not duplicate conflicting state.

Acceptance criteria:
- A first-time reader can navigate run/test/report/performance/plan docs in less than 2 minutes.
- No duplicated or contradictory status claims across plan files.

### MZ4. Add modernization quality checks

- Add lightweight CI checks for stale references and broken internal markdown links.
- Add a doc-consistency check for required plan/status/backlog markers.

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
