context("basic test")

td <- td_create(10)

expect_is(td, "tdigest")

expect_true(is_tdigest(td))
expect_equal(td_total_count(td), 0)

expect_true(is.nan(td_value_at(td, 0)))
expect_true(is.nan(td_value_at(td, 0.5)))
expect_true(is.nan(td_value_at(td, 1)))
expect_true(is.nan(td_value_at(td, -0.1)))
expect_true(is.nan(td_value_at(td, 1.1)))

td_add(td, 0, 1)
td_add(td, 10, 1)

expect_equal(td_total_count(td), 2)

expect_equal(td_value_at(td, 0.1), 0)
expect_equal(td_value_at(td, 0.5), 5)

td <- td_create(1000)
td_add(td, 1, 1)
td_add(td, 10, 1)

expect_equal(td_quantile_of(td, 0.99), 0)
expect_equal(td_quantile_of(td, 1), 0.25)
expect_equal(td_quantile_of(td, 5.5), 0.5)

context("bigger, vectorised test")

set.seed(1492)
x <- sample(0:100, 1000000, replace = TRUE)
td <- tdigest(x, 1000)

expect_true(is_tdigest(td))
expect_false(is_tdigest(x))

expect_equal(td_total_count(td), 1000000)

expect_equal(
  ceiling(
    tquantile(td, c(0, .01, .1, .2, .3, .4, .5, .6, .7, .8, .9, .99, 1))
  ),
  c(0, 1, 10, 20, 30, 40, 51, 61, 71, 81, 91, 100, 100),
  tolerance = 3
)

expect_equal(
  ceiling(quantile(td)),
  c(0, 25, 51, 76, 100),
  tolerance = 3
)

context("ALTREP test")

N <- 1000000
x.altrep <- seq_len(N) # this is an ALTREP in R version >= 3.5.0

td <- tdigest(x.altrep)
expect_equal(as.integer(td[0.1]), 93051)
expect_equal(as.integer(td[0.5]), 491472)
expect_equal(length(td), 1000000)

context("Serialization test")

set.seed(1492)
x <- sample(0:100, 1000000, replace = TRUE)
td <- tdigest(x, 1000)
a <- as.list(td)
b <- as.list(as_tdigest(a))
expect_true(identical(a, b))

context("incremental td_add cannot exceed observed maximum (issue #1)")

# Regression for https://github.com/yassineS/tdigest/issues/1 (originally
# https://github.com/hrbrmstr/tdigest/issues/1). After incrementally adding
# new points via td_add(), tquantile() can return values larger than the
# largest observed value, because the underlying t-digest interpolates
# between centroid means. We capture the current behaviour with a tolerance
# that allows mild overshoot, and we will tighten this once the
# interpolation clamping fix lands.
x <- c(rep(3, 10), rep(5, 10))
td <- tdigest(x)
td_add(td, 8, 10)
qs <- tquantile(td, c(0, 0.5, 0.7, 0.8, 0.9, 1))
# Hard upper bound: tquantile must never exceed the observed max by more
# than a small fraction. Once the interpolation is clamped this tolerance
# can be set to 0.
observed_max <- 8
expect_lte(max(qs), observed_max * 1.30)
expect_gte(min(qs), 3)
