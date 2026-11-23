# Lesson 10: other summary shapes and custom statistics
# tbl_cross(), tbl_continuous(), add_stat(), tbl_custom_summary()

library(gtsummary)
library(dplyr)

# Two-way contingency table
trial |>
  tbl_cross(row = stage, col = trt)

trial |>
  tbl_cross(row = stage, col = trt, percent = "row", margin = "column") |>
  add_p()

# Continuous variable summarised across levels of categorical ones
trial |>
  tbl_continuous(variable = age, by = trt, include = c(grade, stage))

trial |>
  tbl_continuous(
    variable = marker,
    by = trt,
    include = grade,
    statistic = everything() ~ "{mean} ({sd})"
  )

# add_stat() lets you bolt on a column that you compute.
# The function gets the data, the variable name and the by name,
# and must return a one-row data frame (or a single value).
my_cv <- function(data, variable, ...) {
  x <- data[[variable]]
  cv <- sd(x, na.rm = TRUE) / mean(x, na.rm = TRUE) * 100
  tibble(cv = sprintf("%.1f%%", cv))
}

trial |>
  tbl_summary(by = trt, include = c(age, marker)) |>
  add_stat(fns = all_continuous() ~ my_cv) |>
  modify_header(cv ~ "**CV**")

# A Kruskal-Wallis p-value from a different variable layout
kw_p <- function(data, variable, by, ...) {
  p <- kruskal.test(data[[variable]] ~ as.factor(data[[by]]))$p.value
  style_pvalue(p)
}

trial |>
  tbl_summary(by = grade, include = c(age, marker)) |>
  add_stat(fns = everything() ~ kw_p) |>
  modify_header(add_stat_1 ~ "**KW p**")

# tbl_custom_summary(): you write the statistic function
mean_ci <- function(data, full_data, variable, ...) {
  x <- na.omit(data[[variable]])
  ci <- t.test(x)$conf.int
  tibble(mean = mean(x), low = ci[1], high = ci[2])
}

trial |>
  tbl_custom_summary(
    by = trt,
    include = c(age, marker),
    stat_fns = everything() ~ mean_ci,
    statistic = everything() ~ "{mean} ({low}, {high})",
    digits = everything() ~ 1
  ) |>
  modify_footnote_header("Mean (95% CI)", columns = all_stat_cols())

# Try it:
# Cross grade by response, show row percentages and add a p-value.
