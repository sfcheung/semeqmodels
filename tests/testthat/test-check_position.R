# tests/testthat/test-check_position.R

test_that("check_position returns correct direction for single vectors", {
  expect_equal(check_position(c(.5, .5),  c(.75, -.5)), "right")
  expect_equal(check_position(c(-.5, .5), c(-.25, -.75)), "left")
})

test_that("check_position detects collinear cases", {
  # 同方向
  expect_equal(check_position(c(1, 1), c(2, 2)), "collinear")
  # 反方向（仍在同一直线上）
  expect_equal(check_position(c(1, 1), c(-1, -1)), "collinear")
  # 经过原点的水平/垂直线
  expect_equal(check_position(c(1, 0), c(2, 0)), "collinear")
  expect_equal(check_position(c(0, 1), c(0, 2)), "collinear")
})

test_that("check_position supports vectorized matrix input", {
  p1 <- c(.5, .5);  p2 <- c(.75, -.5)
  p3 <- c(-.5, .5); p4 <- c(-.25, -.75)
  
  res <- check_position(rbind(p1, p3), rbind(p2, p4))
  expect_equal(unname(res), c("right", "left"))
  expect_length(res, 2)
})

test_that("check_position returns a character vector", {
  out <- check_position(c(1, 0), c(0, 1))
  expect_type(out, "character")
  expect_true(out %in% c("right", "left", "collinear"))
})

test_that("check_position gives consistent results for vector and matrix inputs", {
  v_result <- check_position(c(.5, .5), c(.75, -.5))
  m_result <- check_position(matrix(c(.5, .5), nrow = 1),
                             matrix(c(.75, -.5), nrow = 1))
  expect_equal(unname(v_result), unname(m_result))
})

test_that("check_position handles multi-row matrices containing collinear cases", {
  from <- rbind(c(1, 1), c(.5, .5), c(1, 0))
  to   <- rbind(c(2, 2), c(.75, -.5), c(0, 1))
  expect_equal(unname(check_position(from, to)),
               c("collinear", "right", "left"))
})