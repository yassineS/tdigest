# tdigest 0.4.3

## Maintainer change

* Yassine Souilmi is maintaining a fork of the package, with plans to
  get it back onto CRAN after its 2026-02-07 archival. The original
  author Bob Rudis remains as `aut`.

## CRAN compliance

* Removed all uses of the non-API `DATAPTR` entry point in compiled code,
  which was the sole reason the package was archived on CRAN on 2026-02-07.
  Reads of `REALSXP` element data now use the public `REAL()` accessor for
  non-ALTREP vectors and `REAL_ELT()` for ALTREP-aware element access.
  Writes to freshly allocated `REALSXP` outputs use `REAL()` directly,
  which is API-stable.
* Bug-reports and URL fields now point to the new GitHub repository.

## Known issues carried over

* Issue #1 (`td_add` producing values larger than the largest input after
  incremental updates) remains under investigation; this is an algorithmic
  matter in the underlying C t-Digest, not a CRAN-policy issue.
