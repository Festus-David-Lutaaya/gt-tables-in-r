# Lesson 12: combining gtsummary tables
# tbl_merge() side by side, tbl_stack() on top of each other,
# tbl_strata() same table for each level of a variable

library(gtsummary)
library(dplyr)
library(survival)

# Univariable vs multivariable
uv <- trial |>
  select(response, age, grade, trt) |>
  tbl_uvregression(
    method = glm, y = response,
    method.args = list(family = binomial),
    exponentiate = TRUE
  )

mv <- glm(response ~ age + grade + trt, data = trial, family = binomial) |>
  tbl_regression(exponentiate = TRUE)

tbl_merge(
  tbls = list(uv, mv),
  tab_spanner = c("**Univariable**", "**Multivariable**")
)

# Two outcomes from the same predictors
t_resp <- glm(response ~ age + trt, data = trial, family = binomial) |>
  tbl_regression(exponentiate = TRUE)
t_death <- coxph(Surv(ttdeath, death) ~ age + trt, data = trial) |>
  tbl_regression(exponentiate = TRUE)

tbl_merge(
  list(t_resp, t_death),
  tab_spanner = c("**Tumour response**", "**Death**")
)

# Stacking: same columns, different row blocks
unadj <- coxph(Surv(ttdeath, death) ~ trt, data = trial) |>
  tbl_regression(exponentiate = TRUE)
adj <- coxph(Surv(ttdeath, death) ~ trt + grade + stage + marker, data = trial) |>
  tbl_regression(exponentiate = TRUE, include = trt)

tbl_stack(
  list(unadj, adj),
  group_header = c("Unadjusted", "Adjusted for grade, stage and marker")
)

# Stratified table: one tbl_summary per grade, merged automatically
trial |>
  select(age, response, trt, grade) |>
  tbl_strata(
    strata = grade,
    .tbl_fun = ~ .x |>
      tbl_summary(by = trt, missing = "no") |>
      add_n(),
    .header = "**Grade {strata}**, N = {n}"
  )

# Stacked instead of side by side
trial |>
  select(age, response, trt, grade) |>
  tbl_strata(
    strata = grade,
    .tbl_fun = ~ tbl_summary(.x, by = trt, missing = "no"),
    .combine_with = "tbl_stack"
  )

# Try it:
# Make a tbl_summary of age and marker by trt for patients who
# responded and another for those who did not, then merge them with
# spanners "Responders" and "Non-responders".
