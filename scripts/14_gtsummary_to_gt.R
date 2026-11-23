# Lesson 14: from gtsummary to gt (and other engines)
# as_gt(), styling the result with gt, modify_table_body(),
# as_flex_table(), as_hux_table(), as_kable()
#
# This is where the two packages meet: gtsummary computes,
# gt finishes the table.

library(gtsummary)
library(gt)
library(dplyr)

tbl <- trial |>
  tbl_summary(by = trt, include = c(age, marker, grade, response)) |>
  add_p() |>
  bold_labels()

gt_tbl <- as_gt(tbl)
class(gt_tbl)

# The gt data keeps gtsummary's hidden helper columns.
# These are the ones you will target most:
#   variable   which variable a row belongs to
#   row_type   "label", "level" or "missing"
#   label      the visible first column
#   stat_1, stat_2 ...  one per 'by' group
#   p.value
tbl$table_body |> select(variable, row_type, label, stat_1, stat_2, p.value)

# Now every gt function is available
gt_tbl |>
  tab_header(
    title = "Patient characteristics",
    subtitle = "Randomised trial, N = 200"
  ) |>
  tab_style(
    style = cell_fill(color = "#EEF2F7"),
    locations = cells_body(rows = row_type == "label")
  ) |>
  tab_style(
    style = cell_text(color = "darkred", weight = "bold"),
    locations = cells_body(columns = p.value, rows = p.value < 0.05)
  ) |>
  tab_options(
    table.font.size = px(13),
    column_labels.font.weight = "bold"
  ) |>
  tab_source_note("Data: gtsummary::trial")

# Highlight one variable's block
gt_tbl |>
  tab_style(
    style = cell_fill(color = "#FFF3CD"),
    locations = cells_body(rows = variable == "grade")
  )

# Re-use the theme from lesson 6
theme_lab <- function(data) {
  data |>
    opt_table_font(font = c("Arial", default_fonts())) |>
    opt_align_table_header(align = "left") |>
    tab_options(
      table.font.size = px(13),
      column_labels.background.color = "#EEF2F7",
      table.border.top.color = "#1F4E79",
      table.border.top.width = px(3)
    )
}

tbl |>
  as_gt() |>
  tab_header(title = "Table 1") |>
  theme_lab()

# Some changes are better made before converting, while gtsummary
# still knows about the structure. modify_table_body() edits the data.
tbl |>
  modify_table_body(
    ~ .x |> mutate(label = ifelse(label == "Age", "Age at enrolment", label))
  ) |>
  as_gt()

# Other output engines
ft <- as_flex_table(tbl)        # flextable, best for Word / PowerPoint
ft

if (requireNamespace("huxtable", quietly = TRUE)) {
  as_hux_table(tbl)            # huxtable, Excel and LaTeX friendly
}

as_kable(tbl)                  # plain markdown

# Rule of thumb:
#   HTML, Quarto, R Markdown html  -> as_gt()
#   Word / PowerPoint with officer -> as_flex_table()
#   quick markdown preview         -> as_kable()

# Try it:
# Build a regression table, convert it with as_gt(), and shade rows
# where the p-value is below 0.05.
