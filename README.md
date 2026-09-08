# Govenv

Compile formally governed projects into reproducible development runtimes. A type system for your repository.

## Bootstrap

Govenv currently uses devenv only as its Stage 0 bootstrap environment.

The bootstrap uses devenv tag `v2.3` (`e0781f7bee573eefcab4a7d2788fd9b455560ca2`), which reports `devenv 2.3.0+e0781f7`.

## Test

Run the test suite with the pinned devenv tag:

```bash
nix run github:cachix/devenv/v2.3 -- test
```

This type-checks the literate Agda entrypoint `Govenv.lagda.md` and its imported Govenv modules.

## Documentation

Build the literate Agda documentation locally with:

```bash
nix run github:cachix/devenv/v2.3 -- tasks run govenv:docs
```

The static site is written to `_site/` and deployed to GitHub Pages from `main`.

## Releases

Releases are managed by Release Please from Conventional Commits on `main`.

- `feat` proposes a minor version bump.
- `fix` proposes a patch version bump.
- `!` or `BREAKING CHANGE` proposes a major version bump.
- Other configured commit types are included in the changelog without forcing a version bump.

Release Please maintains a release pull request. Merging that pull request creates the immutable GitHub release and `vX.Y.Z` tag automatically.
