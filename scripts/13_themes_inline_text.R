# Lesson 13: gtsummary themes and reporting numbers in text
# theme_gtsummary_journal(), theme_gtsummary_compact(),
# theme_gtsummary_language(), set_gtsummary_theme(), inline_text()

library(gtsummary)
library(dplyr)

tbl <- trial |>
  tbl_summary(by = trt, include = c(age, grade, response)) |>
  add_p()

# Themes change defaults for every table made after them
theme_gtsummary_journal(journal = "jama")
tbl <- trial |>
  tbl_summary(by = trt, include = c(age, grade, response)) |>
  add_p()
tbl

reset_gtsummary_theme()

theme_gtsummary_compact()
trial |> tbl_summary(include = c(age, grade))
reset_gtsummary_theme()

# Themes stack
theme_gtsummary_journal("lancet")
theme_gtsummary_compact()
trial |> tbl_summary(by = trt, include = c(age, grade)) |> add_p()
reset_gtsummary_theme()

# Your own theme is just a named list
my_theme <- list(
  "tbl_summary-arg:statistic" = list(
    all_continuous() ~ "{mean} ({sd})",
    all_categorical() ~ "{n} ({p}%)"
  ),
  "tbl_summary-arg:digits" = list(all_continuous() ~ 1),
  "pkgwide-fn:pvalue_fun" = label_style_pvalue(digits = 3)
)
set_gtsummary_theme(my_theme)
trial |> tbl_summary(by = trt, include = c(age, marker)) |> add_p()
reset_gtsummary_theme()

# inline_text() pulls numbers out of a table for your results paragraph
tbl <- trial |>
  tbl_summary(by = trt, include = c(age, response)) |>
  add_p()

inline_text(tbl, variable = age, column = "Drug A")
inline_text(tbl, variable = response, column = "Drug B")
inline_text(tbl, variable = age, column = "p.value")

# from a regression table
m <- glm(response ~ age + trt, data = trial, family = binomial) |>
  tbl_regression(exponentiate = TRUE)

inline_text(m, variable = trt, level = "Drug B")
inline_text(m, variable = age, pattern = "OR {estimate} (95% CI {conf.low}, {conf.high})")

# In R Markdown / Quarto you would write:
#   Median age in arm A was `r inline_text(tbl, variable = age, column = "Drug A")`.

# Try it:
# Make your own theme that reports median [IQR] and use inline_text() to
# write one sentence comparing marker levels between arms.
