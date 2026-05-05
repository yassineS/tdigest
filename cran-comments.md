# cran-comments.md

## Resubmission of an archived package

`tdigest` was archived on CRAN on 2026-02-07 because the previous maintainer
was no longer responding to CRAN's reminders. The sole technical reason
flagged in the final CRAN checks was a `WARN` for use of the non-API entry
point `DATAPTR` in compiled code on r-devel flavours.

I have adopted the package with the agreement of the community (see GitHub
issue #6 in the source repository) and am submitting `0.4.3`, which:

* Replaces every `DATAPTR` use in `src/tdigest-main.c` with the public
  `REAL()` accessor (for non-ALTREP / freshly-allocated vectors) and
  `REAL_ELT()` (for ALTREP-aware reads). No other behavioural changes.
* Updates `Maintainer:` and contact details, with explicit retention of
  the original author Bob Rudis as `aut`.
* Updates `BugReports:` and `URL:` to the new GitHub home.

## Test environments

* local macOS arm64, R 4.6.0 -- no errors, no warnings, only environmental
  notes (CLAUDE.md addressed via `.Rbuildignore`; `inconsolata.sty` /
  HTML Tidy are local toolchain notes).
* GitHub Actions (`R-CMD-check.yaml`): macOS-latest, windows-latest,
  ubuntu-latest on R-release, R-devel and R-oldrel.

## R CMD check results

0 errors | 0 warnings | 0 notes (modulo the standard "New submission /
Package was archived on CRAN" incoming-feasibility note).

## Reverse dependencies

`tdigest` had no reverse dependencies on CRAN at the time of archival.
