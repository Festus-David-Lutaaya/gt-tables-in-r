# Lesson 8: gtsummary basics with tbl_summary()
# by, include, label, statistic, digits, type, value, missing, sort
#
# gtsummary does the statistics and hands you a table. Under the hood it
# is a gt table, so everything from lessons 1-7 still applies later.

library(gtsummary)
library(dplyr)

trial   # 200 patients, two treatment arms
?trial

# One line gives a full descriptive table
tbl_summary(trial)

# Pick the variables
trial |>
  tbl_summary(include = c(age, grade, response))

# Split by a group
trial |>
  tbl_summary(by = trt, include = c(age, marker, grade, stage, response))

# Labels
trial |>
  tbl_summary(
    by = trt,
    include = c(age, marker, grade),
    label = list(age ~ "Age (years)", marker ~ "Marker level (ng/mL)")
  )

# Selectors pick groups of variables:
#   all_continuous(), all_categorical(), all_dichotomous(), all_of(), everything()
trial |>
  tbl_summary(
    by = trt,
    include = c(age, marker, grade, response),
    statistic = list(
      all_continuous() ~ "{mean} ({sd})",
      all_categorical() ~ "{n} / {N} ({p}%)"
    )
  )

# Several statistics on separate rows for continuous variables
trial |>
  tbl_summary(
    by = trt,
    include = c(age, marker),
    type = all_continuous() ~ "continuous2",
    statistic = all_continuous() ~ c("{mean} ({sd})", "{median} ({p25}, {p75})", "{min}, {max}")
  )

# Digits
trial |>
  tbl_summary(
    include = c(age, marker, grade),
    digits = list(age ~ 0, marker ~ 2, all_categorical() ~ c(0, 1))
  )

# Variable types. A 0/1 or Yes/No variable is shown on one row by default.
trial |>
  tbl_summary(include = c(response, death))

# Show both levels of a dichotomous variable
trial |>
  tbl_summary(include = response, type = response ~ "categorical")

# Or the level you care about
trial |>
  tbl_summary(include = grade, type = grade ~ "dichotomous", value = grade ~ "III")

# Missing data
trial |>
  tbl_summary(include = c(age, response), missing = "always")

trial |>
  tbl_summary(include = c(age, response), missing = "no")

trial |>
  tbl_summary(include = c(age, response), missing_text = "Not recorded")

# Sort categorical levels by frequency
trial |>
  tbl_summary(include = grade, sort = all_categorical() ~ "frequency")

# Percentages by row instead of column
trial |>
  tbl_summary(by = trt, include = grade, percent = "row")

# Try it:
# Summarise age, stage and death by grade. Report age as median (IQR),
# show 1 decimal place on percentages and hide missing rows.
