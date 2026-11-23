# Lesson 18 (clinical 3): efficacy models and a subgroup (forest) table
# tbl_regression() + tbl_merge() for the models,
# a hand-built gt table for the subgroups, with a small forest plot.

library(gtsummary)
library(gt)
library(dplyr)
library(purrr)
library(survival)
library(broom)

source("R/clinical_data.R")

# Response at week 12 ------------------------------------------------

uv <- adsl |>
  select(RESPONSE, ARM, AGE, SEX, HIV) |>
  tbl_uvregression(
    method = glm, y = RESPONSE,
    method.args = list(family = binomial),
    exponentiate = TRUE,
    hide_n = TRUE
  )

mv <- glm(RESPONSE ~ ARM + AGE + SEX + HIV, data = adsl, family = binomial) |>
  tbl_regression(exponentiate = TRUE) |>
  add_global_p(keep = TRUE)

tbl_merge(list(uv, mv), tab_spanner = c("**Unadjusted**", "**Adjusted**")) |>
  bold_labels() |>
  as_gt() |>
  tab_header(title = "Table 14.2.1 Logistic regression for week 12 response")

# Time to clinical failure ----------------------------------------

cox <- coxph(Surv(TTE, 1 - CNSR) ~ ARM + AGE + HIV, data = adsl)

tbl_regression(cox, exponentiate = TRUE) |>
  add_n(location = "level") |>
  bold_p() |>
  as_gt() |>
  tab_header(title = "Table 14.2.2 Cox model for time to clinical failure")

# Subgroup analysis: Drug 20 mg vs Placebo -----------------------

two_arm <- adsl |>
  filter(ARM %in% c("Placebo", "Drug 20 mg")) |>
  mutate(TRT = as.integer(ARM == "Drug 20 mg"))

fit_one <- function(d) {
  rates <- tapply(d$RESPONSE, d$TRT, mean)
  # with 0% or 100% response in an arm the odds ratio is not estimable
  if (length(rates) < 2 || any(rates %in% c(0, 1))) {
    return(tibble(n = nrow(d), resp_pbo = rates["0"], resp_trt = rates["1"],
                  or = NA_real_, low = NA_real_, high = NA_real_))
  }
  m <- glm(RESPONSE ~ TRT, data = d, family = binomial)
  # Wald intervals: quicker than profile likelihood and fine for a table
  tidy(m) |>
    filter(term == "TRT") |>
    transmute(
      n = nrow(d),
      resp_pbo = mean(d$RESPONSE[d$TRT == 0]),
      resp_trt = mean(d$RESPONSE[d$TRT == 1]),
      or = exp(estimate),
      low = exp(estimate - 1.96 * std.error),
      high = exp(estimate + 1.96 * std.error)
    )
}

interaction_p <- function(var) {
  f0 <- as.formula(paste("RESPONSE ~ TRT +", var))
  f1 <- as.formula(paste("RESPONSE ~ TRT *", var))
  m0 <- glm(f0, data = two_arm, family = binomial)
  m1 <- glm(f1, data = two_arm, family = binomial)
  anova(m0, m1, test = "LRT")$`Pr(>Chi)`[2]
}

subgroup_vars <- c(Sex = "SEX", `Age group` = "AGEGR1", `HIV status` = "HIV", Site = "SITE")

subgroups <- imap(subgroup_vars, function(var, nice) {
  two_arm |>
    group_by(level = as.character(.data[[var]])) |>
    group_modify(~ fit_one(.x)) |>
    ungroup() |>
    mutate(group = nice, p_int = c(interaction_p(var), rep(NA, n() - 1)))
}) |>
  list_rbind()

overall <- fit_one(two_arm) |>
  mutate(level = "All patients", group = "Overall", p_int = NA)

forest_data <- bind_rows(overall, subgroups) |>
  mutate(plot = NA_character_)

# a tiny SVG forest marker for each row, log scale from 0.1 to 10
forest_svg <- function(or, low, high, width = 160, height = 18) {
  to_x <- function(v) {
    v <- pmin(pmax(v, 0.1), 10)
    (log10(v) + 1) / 2 * width
  }
  x1 <- to_x(1)
  sprintf(
    '<svg width="%d" height="%d">
       <line x1="%.1f" y1="0" x2="%.1f" y2="%d" stroke="#999" stroke-dasharray="2,2"/>
       <line x1="%.1f" y1="%.1f" x2="%.1f" y2="%.1f" stroke="#333"/>
       <rect x="%.1f" y="%.1f" width="7" height="7" fill="#1F4E79"/>
     </svg>',
    width, height, x1, x1, height,
    to_x(low), height / 2, to_x(high), height / 2,
    to_x(or) - 3.5, height / 2 - 3.5
  )
}

forest_data |>
  gt(rowname_col = "level", groupname_col = "group") |>
  fmt_percent(columns = c(resp_pbo, resp_trt), decimals = 0) |>
  fmt_number(columns = c(or, low, high), decimals = 2) |>
  cols_merge(columns = c(or, low, high), pattern = "<<{1} ({2}, {3})>>") |>
  sub_missing(columns = or, missing_text = "NE") |>
  fmt(columns = p_int, fns = function(x) ifelse(is.na(x), "", style_pvalue(x))) |>
  text_transform(
    locations = cells_body(columns = plot),
    fn = function(x) {
      pmap_chr(forest_data[c("or", "low", "high")], function(or, low, high) {
        if (is.na(or)) "" else forest_svg(or, low, high)
      })
    }
  ) |>
  cols_label(
    n = "N",
    resp_pbo = "Placebo",
    resp_trt = "Drug 20 mg",
    or = "Odds ratio (95% CI)",
    plot = html("0.1 &nbsp;&nbsp;&nbsp;&nbsp; 1 &nbsp;&nbsp;&nbsp;&nbsp; 10"),
    p_int = "Interaction p"
  ) |>
  tab_spanner("Response rate", columns = c(resp_pbo, resp_trt)) |>
  cols_move(plot, after = or) |>
  cols_align("center", columns = -level) |>
  tab_header(
    title = "Figure-table 14.2.3 Week 12 response by subgroup",
    subtitle = "Drug 20 mg vs placebo"
  ) |>
  tab_source_note("Odds ratios > 1 favour Drug 20 mg. NE = not estimable. Interaction p from likelihood ratio test.") |>
  tab_style(cell_text(weight = "bold"), cells_row_groups()) |>
  opt_align_table_header("left")

# Try it:
# Repeat the subgroup table with hazard ratios from a Cox model
# for time to clinical failure instead of odds ratios.
