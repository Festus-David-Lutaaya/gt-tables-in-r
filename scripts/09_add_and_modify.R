# Lesson 9: adding columns and changing the look of a gtsummary table
# add_overall(), add_n(), add_p(), add_q(), add_ci(), add_difference(),
# add_stat_label(), bold_labels(), italicize_levels(), bold_p(),
# show_header_names(), modify_header(), modify_spanning_header(),
# modify_footnote_header(), modify_caption()

library(gtsummary)
library(dplyr)

base <- trial |>
  tbl_summary(by = trt, include = c(age, marker, grade, response))

# add_*() functions add columns
base |> add_overall()
base |> add_overall(last = TRUE)
base |> add_n()
base |> add_p()

# Choose the test yourself
base |>
  add_p(
    test = list(all_continuous() ~ "t.test", all_categorical() ~ "fisher.test"),
    pvalue_fun = label_style_pvalue(digits = 3)
  )

# False discovery rate adjusted p-values
base |> add_p() |> add_q(method = "fdr")

# Confidence intervals. For continuous variables add_ci() gives a CI
# for the mean, so report the mean in the first place.
trial |>
  tbl_summary(
    by = trt,
    include = c(age, marker, response),
    statistic = all_continuous() ~ "{mean} ({sd})",
    missing = "no"
  ) |>
  add_ci()

# Difference between two groups with its CI and p-value
trial |>
  tbl_summary(
    by = trt,
    include = c(age, marker, response),
    statistic = all_continuous() ~ "{mean} ({sd})",
    missing = "no"
  ) |>
  add_difference()

# Put the statistic type next to the label instead of in a footnote
base |> add_stat_label()

# Cosmetic helpers
base |>
  add_p() |>
  bold_labels() |>
  italicize_levels() |>
  bold_p(t = 0.05)

# To change headers you need the internal column names. Ask the table:
base |> add_p() |> show_header_names()

# Then use them
base |>
  add_p() |>
  modify_header(
    label ~ "**Characteristic**",
    all_stat_cols() ~ "**{level}**  \nN = {n}",
    p.value ~ "**P**"
  ) |>
  modify_spanning_header(all_stat_cols() ~ "**Treatment received**") |>
  modify_footnote_header(
    footnote = "Median (Q1, Q3); n (%)",
    columns = all_stat_cols(),
    replace = TRUE
  ) |>
  modify_caption("**Table 1. Patient characteristics by treatment**")

# Hide or show columns
base |> add_p() |> modify_column_hide(columns = p.value)

# Try it:
# Summarise age, stage and response by death status. Add an overall
# column, p-values, bold significant p-values, and give the table a caption.
