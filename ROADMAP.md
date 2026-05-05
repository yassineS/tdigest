# tdigest maintenance roadmap

This file tracks the work required to bring `tdigest` back onto CRAN and
keep it healthy. It is `.Rbuildignore`d and is not shipped to CRAN.

## Phase 1 — CRAN re-instatement (in flight)

| Task | Status |
| ---- | ------ |
| Replace non-API `DATAPTR` calls in `src/tdigest-main.c` | done in 0.4.3 |
| Update `Maintainer:` and contact details | done in 0.4.3 |
| Move `BugReports:` / `URL:` to GitHub | done in 0.4.3 |
| Add GitHub Actions workflows (`R-CMD-check`, `test-coverage`, `lint`) | done |
| Add `cran-comments.md` | done |
| Verify locally with `R CMD check --as-cran` | done (no compiled-code WARN) |
| Submit to CRAN | pending |

## Phase 2 — Algorithmic correctness

### Issue #1 — incremental `td_add` overshoots the observed maximum

Reproducer (Aaron Robotham, hrbrmstr#1):

```r
x  <- c(rep(3, 10), rep(5, 10))
td <- tdigest(x)
td_add(td, 8, 10)
tquantile(td, c(0.7, 0.8, 0.9))
# returns values larger than 8 (e.g. 8.27, 9.91)
```

Root cause: `td_value_at()` in `src/tdigest.c` linearly interpolates
between adjacent centroid means using count-weighted distance. When the
buffered (`unmerged`) point at 8 is merged late, the merge step can
produce a centroid layout in which the linear interpolation, evaluated
at a `goal` count strictly less than the cumulative count of the last
centroid, produces a result above that last centroid's mean.

Plan:

1. Add the regression test (already added in `tests/testthat/test-tdigest.R`).
2. Clamp interpolated values in `td_value_at()` to the closed interval
   `[nl->mean, nr->mean]` for the bracketing centroid pair, mirroring the
   convention in upstream `ajwerner/tdigest` and `tdunning/t-digest`.
3. Investigate whether the `normalizer` formula
   `compression / (2π · N · log N)` matches Dunning's reference; the
   reference tracks `4 · q · (1-q) · N / compression`. If the formula
   itself is wrong the centroids will be over-compressed at small N and
   the symptom Aaron reported is a side-effect.
4. Tighten the regression-test tolerance to 0 once 2 lands.

### Issue #6 — "tdigest is off CRAN"

Closes once Phase 1 succeeds.

## Phase 3 — Hygiene

* Move from `.travis.yml` / `.build.yml` (sourcehut) to GitHub-only CI.
* Convert `README.qmd` build to a GHA workflow, drop the local cache files.
* Replace the manually-tracked `roxygen2` line endings with a `make doc`
  target.
* Set up `pkgdown` site under `gh-pages`.
