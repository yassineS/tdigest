# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Global Claude Code Instructions

- IMPORTANT: Preserve the original code and its logic as much as possible when making changes.
- IMPORTANT: Always use Australian/UK English, including in documentation, variable names, and function names.
- IMPORTANT: Be concise, unless asked otherwise.

## Project context

`tdigest` is an R wrapper around a portable C implementation of Ted Dunning's
t-digest streaming-quantile data structure. It was archived from CRAN on
2026-02-07 because the previous maintainer did not address a `WARN` for the
non-API symbol `DATAPTR`. This fork (`yassineS/tdigest`) is the active
maintenance line; ROADMAP.md tracks the remaining work.

## Repository layout

- `src/tdigest.h`, `src/tdigest.c` — vendored portable C implementation
  (Andrew Werner's port of Dunning's algorithm). Do not refactor for style;
  upstream may be re-synced.
- `src/tdigest-main.c` — R glue. The DATAPTR replacement happened here.
- `src/init.c` — registered `.Call` entry points.
- `R/create.R`, `R/util.R` — public R API.
- `tests/testthat/test-tdigest.R` — single test file; new suites should be
  added as `test-*.R` files alongside it.
- `inst/COPYRIGHTS` — required by CRAN; reflects upstream attribution.

## Common commands

Dev environment is managed via `renv` (lockfile in `renv.lock`). The first
shell in a fresh checkout should run:

```r
renv::restore()
```

Day-to-day:

```bash
# regenerate Rd files from roxygen comments
R -e 'roxygen2::roxygenise()'

# build a source tarball
R CMD build .

# full CRAN-grade check (use --no-manual locally if inconsolata.sty is missing)
R CMD check --as-cran tdigest_*.tar.gz

# run tests only (fast iteration)
R -e 'devtools::test()'

# coverage
R -e 'covr::package_coverage()'
```

When R CMD check is run outside renv, point it at the project library:

```bash
R_LIBS_USER="$(R -q -e 'cat(.libPaths()[1])' | tail -1)" \
  R CMD check --as-cran tdigest_*.tar.gz
```

## Architectural notes

- The C type `td_histogram_t` is a flexible-array-member struct; ALL of its
  storage is one `malloc` allocation sized by `td_required_buf_size()`.
  Never copy it shallowly.
- `td_add()` writes into an unmerged buffer; `merge()` only runs when the
  buffer fills or when a query forces it. This is why `td_value_at()` and
  `td_quantile_of()` always call `merge()` first.
- The R-level `tdigest` object is an `EXTPTRSXP` wrapping the C struct,
  with a registered finaliser (`td_finalizer`). `is_null_xptr_()` checks
  whether the pointer has been cleared (e.g., after deserialisation
  round-trips that didn't go through `as_tdigest()`).
- Element reads from `REALSXP` inputs use `REAL_ELT()` so that ALTREP
  vectors are not materialised. Writes to freshly-allocated outputs use
  `REAL()` directly. Do **not** reintroduce `DATAPTR` — it is non-API and
  will re-archive the package.

## CI

GitHub Actions live under `.github/workflows/`:

- `R-CMD-check.yaml` — macOS / Windows / Ubuntu × release / devel / oldrel.
- `test-coverage.yaml` — codecov upload.
- `lint.yaml` — `spelling::spell_check_package()` + `lintr::lint_package()`.

## Known issues being tracked

See `ROADMAP.md`. The active algorithmic question is upstream issue #1
(incremental `td_add` overshoot); a regression test is already in place.
