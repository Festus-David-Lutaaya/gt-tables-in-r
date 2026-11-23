# Lesson 11: regression tables
# tbl_regression(), tbl_uvregression(), add_global_p(),
# add_significance_stars(), add_glance_source_note()

library(gtsummary)
library(dplyr)
library(survival)

# Linear model
m_lm <- lm(marker ~ age + grade + trt, data = trial)
tbl_regression(m_lm)

# Logistic model: exponentiate to get odds ratios
m_glm <- glm(response ~ age + stage + trt, data = trial, family = binomial)

tbl_regression(m_glm, exponentiate = TRUE)

tbl_regression(
  m_glm,
  exponentiate = TRUE,
  label = list(age ~ "Age (years)", trt ~ "Treatment"),
  pvalue_fun = label_style_pvalue(digits = 3)
) |>
  bold_p() |>
  bold_labels()

# One overall p-value per categorical term (likelihood ratio test)
tbl_regression(m_glm, exponentiate = TRUE) |>
  add_global_p()

# Model fit statistics as a source note
tbl_regression(m_lm) |>
  add_glance_source_note(include = c(r.squared, AIC, nobs))

# Stars instead of p-values
tbl_regression(m_glm, exponentiate = TRUE) |>
  add_significance_stars(hide_ci = FALSE, hide_p = TRUE)

# Cox model
m_cox <- coxph(Surv(ttdeath, death) ~ age + grade + trt, data = trial)
tbl_regression(m_cox, exponentiate = TRUE)

# Univariable models, one per predictor
trial |>
  select(response, age, marker, grade, stage, trt) |>
  tbl_uvregression(
    method = glm,
    y = response,
    method.args = list(family = binomial),
    exponentiate = TRUE
  ) |>
  bold_p()

# Univariable and multivariable side by side is a merge (lesson 12)

# Try it:
# Fit a Cox model of death on stage and marker. Show hazard ratios,
# a global p-value for stage, and bold p < 0.05.
