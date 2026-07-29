# Legacy Compatibility Path

This directory is a compatibility layer.

Canonical MATLAB sources now live in `src/matlab`.
Wrappers in this folder forward function calls to the canonical location.
Use `src/matlab/Main_Program.m` as the primary entrypoint.
