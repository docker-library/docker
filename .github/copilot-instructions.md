## Purpose

This file helps AI coding agents become productive quickly in the `docker` official-image repository clone found at the repo root.

Keep guidance short and actionable. When in doubt, prefer touching metadata (`versions.json`, templates, scripts) and small scripts over bulk reformatting.

## Big picture (how the repo is organized)

- This repo is the source for the `docker` Official Image. The core metadata lives in `versions.json`.
- Each supported release has a folder named like `28/` containing variant subfolders (`cli/`, `dind/`, `dind-rootless/`, `windows/...`). Example: `28/cli/Dockerfile` and `28/dind/Dockerfile`.
- Top-level templates: `Dockerfile-cli.template`, `Dockerfile-dind.template`, and `Dockerfile-dind-rootless.template` are used to generate per-version Dockerfiles by `apply-templates.sh`.
- Entrypoints and helper scripts live both at the repo root and inside variant dirs, e.g. `docker-entrypoint.sh`, `dockerd-entrypoint.sh`, and `28/cli/docker-entrypoint.sh`.
- Automation scripts that drive tags/metadata generation include `versions.sh`, `generate-stackbrew-library.sh`, `apply-templates.sh`, and `update.sh`.

## Key conventions and patterns (concrete, discoverable rules)

- versions and variants: `versions.json` defines each release (top-level key `28`) with `arches`, `variants`, `version`, `buildx`, and `compose` metadata. Example: `versions.json -> 28 -> arches -> amd64 -> dockerUrl`.
- Variant naming: directory names under a version (e.g. `cli`, `dind`, `dind-rootless`, `windows/windowsservercore-ltsc2025`) map directly to entries in `versions.json` "variants".
- Arch/URL selectors: scripts use jq selectors like `.[env.version].arches | to_entries[] | select(.value[$selector])` where `$selector` is `dockerUrl` or `rootlessExtrasUrl` for rootless variants. Keep that shape when changing `versions.json`.
- Parent image detection: scripts parse `FROM` lines in Dockerfiles (see `generate-stackbrew-library.sh` and `getArches()` / `dirCommit()` helpers). Don't rename `FROM` targets without checking `getArches()` logic.
- Generated vs. source files: some files are produced by scripts (templates -> per-version Dockerfiles). Prefer editing templates or the source metadata rather than directly editing generated files unless you also update the generator.

## Build / validate / debug workflows (practical commands)

- Most automation is shell-based. Use a POSIX shell (Linux, WSL, Git Bash). On Windows, run these from WSL or Git for Windows (MSYS) to avoid incompatibilities.
- Quick validation after metadata changes:

  - Update metadata and templates, then run `./generate-stackbrew-library.sh <version>` (or without args to run for all versions). This prints the stackbrew / library metadata and will surface jq / bash errors.
  - `./update.sh` is a thin wrapper that runs `versions.sh` and `apply-templates.sh` and is helpful after changing `versions.json`.

- Building images locally: the repo expects modern Docker buildx/buildkit workflows. The repository references `buildx` binaries in `versions.json` and comments `Builder: buildkit`. Use `docker buildx` with appropriate platforms when validating multi-arch behavior.

## Integration points and external dependencies

- Binary artifacts and tools are referenced from external URLs in `versions.json` (e.g., `dockerUrl`, `rootlessExtrasUrl`, `buildx.url`, `compose.url`). Changes to those keys must keep the same structure.
- The `generate-stackbrew-library.sh` script consults the official-images library to compute supported arches (`getArches()` uses a remote `official-images` base by default).

## Safe editing checklist for AI agents

1. Find the relevant version dir (e.g. `28/cli`) and `versions.json` entry.
2. Prefer editing `versions.json` and templates (`Dockerfile-*.template`) over changing many generated Dockerfiles.
3. Run `./apply-templates.sh` and `./generate-stackbrew-library.sh <version>` locally (in WSL/Git Bash) to validate your change.
4. When changing an entrypoint script, check both the root copy and per-version copies (e.g. `docker-entrypoint.sh`, `28/cli/docker-entrypoint.sh`).
5. For updates that affect arch selection or parent images, inspect `generate-stackbrew-library.sh` (functions `getArches`, `dirCommit`, `versionArches`) before editing.

## Small contract for PR changes

- Inputs: edits to `versions.json`, templates, Dockerfiles, or helper scripts.
- Output: updated templates, version metadata, generated Dockerfiles and Stackbrew output.
- Error modes: jq parsing errors, missing `Dockerfile` in a variant dir, mismatched `variants` vs. directories.
- Success criteria: `./generate-stackbrew-library.sh <version>` runs without errors and prints expected Tags/Directory lines for the changed version.

## Examples (where to look)

- Metadata: `versions.json` (see `28` entry)
- Template logic: `apply-templates.sh`, `Dockerfile-cli.template`, `Dockerfile-dind.template`
- Metadata generator: `generate-stackbrew-library.sh` (uses `jq`, `git log`, and `awk` to produce tags/architectures)
- Entrypoints: `docker-entrypoint.sh`, `dockerd-entrypoint.sh`, `modprobe.sh`

If anything is unclear or you need deeper detail (for example, a walkthrough of adding a new version from scratch), say which part you want expanded and I'll iterate on this file.
