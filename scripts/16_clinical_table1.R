# Lesson 16 (clinical 1): baseline demographics, the "Table 1"
# gtsummary for the numbers, gt for the finish.

library(gtsummary)
library(gt)
library(dplyr)

source("R/clinical_data.R")
glimpse(adsl)

# Start simple
adsl |>
  tbl_summary(by = ARM, include = c(AGE, SEX, BMI))

# The full table
t1 <- adsl |>
  tbl_summary(
    by = ARM,
    include = c(AGE, AGEGR1, SEX, WEIGHT, BMI, HIV, SITE, BASE_VL),
    label = list(
      AGE ~ "Age, years",
      AGEGR1 ~ "Age group",
      SEX ~ "Sex",
      WEIGHT ~ "Weight, kg",
      BMI ~ "BMI, kg/m²",
      HIV ~ "HIV status",
      SITE ~ "Study site",
      BASE_VL ~ "Baseline viral load, copies/mL"
    ),
    type = list(c(AGE, WEIGHT, BMI) ~ "continuous2"),
    statistic = list(
      all_continuous2() ~ c("{mean} ({sd})", "{median} ({p25}, {p75})", "{min}, {max}"),
      BASE_VL ~ "{median} ({p25}, {p75})",
      all_categorical() ~ "{n} ({p}%)"
    ),
    digits = list(all_continuous() ~ 1, BASE_VL ~ 0),
    missing_text = "Missing"
  ) |>
  add_overall(col_label = "**Total**  \nN = {N}") |>
  modify_header(
    label ~ "",
    all_stat_cols(stat_0 = FALSE) ~ "**{level}**  \nN = {n}"
  ) |>
  modify_spanning_header(c(stat_2, stat_3) ~ "**Active treatment**") |>
  remove_footnote_header(columns = all_stat_cols()) |>
  bold_labels()

t1

# Baseline tables in trials usually do NOT test for differences
# between randomised arms (CONSORT advice). If you need them anyway:
# t1 |> add_p()

# Finish in gt
t1_gt <- t1 |>
  as_gt() |>
  tab_header(
    title = "Table 14.1.1 Demographic and baseline characteristics",
    subtitle = "Safety population"
  ) |>
  tab_footnote(
    footnote = "BMI = weight (kg) / height (m)².",
    locations = cells_body(columns = label, rows = variable == "BMI" & row_type == "label")
  ) |>
  tab_source_note("Continuous: mean (SD), median (Q1, Q3), min, max. Categorical: n (%).") |>
  tab_source_note("Simulated data for teaching.") |>
  opt_align_table_header(align = "left") |>
  tab_options(
    table.font.size = px(12),
    heading.title.font.size = px(15),
    heading.title.font.weight = "bold",
    table.border.top.color = "black",
    column_labels.border.bottom.color = "black",
    table_body.hlines.color = "white",
    table.border.bottom.color = "black",
    data_row.padding = px(2)
  )

t1_gt

dir.create("output", showWarnings = FALSE)
gtsave(t1_gt, "output/16_table1.html")
gtsave(t1_gt, "output/16_table1.docx")

# Try it:
# Make the same table split by SEX instead of ARM, and put the
# drug arms under one spanner when you go back to ARM.
