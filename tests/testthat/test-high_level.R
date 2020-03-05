test_that("ncaa_team_stats works", {

    df <- ncaa_team_stats(2019)
  expect_is(df, "data.frame")
})

test_that("get_bracket_data works", {
    df <- get_bracket_data(2019)
    expect_is(df, "data.frame")
})
