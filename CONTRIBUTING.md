# Contributing

## Branching and Pull Requests

- Start from `main` and use a short-lived branch for each change.
- Prefer branch names that describe the scope, such as `feat/*`, `test/*`, `perf/*`, or `docs/*`.
- Open a pull request back into `main` when the branch is ready.
- Keep changes small and focused so they are easy to review and merge.
- Use the repository's PR workflow for refactoring and maintenance changes.
- Delete merged local and remote branches after the PR lands.

## MATLAB Compatibility

- Keep changes compatible with MATLAB R2017a.
- Use the repository's existing CLI pattern for automation: `-nosplash -nodesktop -wait -r`.
- Avoid introducing syntax or APIs that are newer than R2017a unless the repository baseline changes.

## Validation Expectations

- Run `run_all_tests` before opening a PR for code changes.
- Use `run('tests/run_tests_with_coverage.m')` when you want coverage output.
- Use `benchmark_solver` and `ci_performance_guardrail` for performance-related changes.

## Workflow Notes

- Keep README command examples canonical and minimal.
- Update `docs/MODERNIZATION_PLAN.md` when a milestone or workstream changes state.
