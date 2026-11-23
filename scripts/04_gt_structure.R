# Lesson 4: table structure
# stub and row groups, tab_spanner(), tab_stubhead(), tab_row_group(),
# summary_rows(), grand_summary_rows(), tab_footnote(), cells_*() locations

library(gt)
library(dplyr)

cars <- gtcars |>
  filter(ctry_origin %in% c("Germany", "Italy")) |>
  select(ctry_origin, mfr, model, hp, trq, mpg_c, mpg_h, msrp) |>
  group_by(ctry_origin) |>
  slice_head(n = 4) |>
  ungroup()

# Row groups from a column
tbl <- cars |>
  gt(rowname_col = "model", groupname_col = "ctry_origin")
tbl

# A label above the stub
tbl |> tab_stubhead(label = "Model")

# Spanners group columns under a shared heading
tbl |>
  tab_spanner(label = "Performance", columns = c(hp, trq)) |>
  tab_spanner(label = "Fuel economy", columns = starts_with("mpg"))

# Spanners can stack. level = 2 sits above level 1.
tbl |>
  tab_spanner(label = "City", columns = mpg_c) |>
  tab_spanner(label = "Highway", columns = mpg_h) |>
  tab_spanner(label = "Miles per gallon", columns = c(mpg_c, mpg_h), level = 2)

# Shortcut: tab_spanner_delim() builds spanners from column names
wide <- tibble(
  site = c("Kampala", "Gulu", "Mbarara"),
  male_n = c(120, 80, 95),
  male_pct = c(0.52, 0.47, 0.50),
  female_n = c(110, 90, 95),
  female_pct = c(0.48, 0.53, 0.50)
)

wide |>
  gt(rowname_col = "site") |>
  tab_spanner_delim(delim = "_") |>
  fmt_percent(columns = ends_with("pct"), decimals = 0)

# Build row groups by hand when there is no grouping column
gtcars |>
  select(model, hp, msrp) |>
  slice_head(n = 8) |>
  gt(rowname_col = "model") |>
  tab_row_group(label = "Under 600 hp", rows = hp < 600) |>
  tab_row_group(label = "600 hp and above", rows = hp >= 600) |>
  row_group_order(groups = c("Under 600 hp", "600 hp and above"))

# Summary rows within each group
tbl |>
  summary_rows(
    columns = c(hp, msrp),
    fns = list(Mean = ~ mean(.), Max = ~ max(.)),
    fmt = ~ fmt_number(., decimals = 0)
  )

# One summary for the whole table
tbl |>
  grand_summary_rows(
    columns = c(hp, msrp),
    fns = list(Overall_mean = ~ mean(.)),
    fmt = ~ fmt_number(., decimals = 0)
  )

# Footnotes need a location. The cells_*() helpers point at parts of the table:
#   cells_title(), cells_column_labels(), cells_column_spanners(),
#   cells_stub(), cells_body(), cells_row_groups(), cells_summary() ...
tbl |>
  tab_spanner(label = "Performance", columns = c(hp, trq)) |>
  tab_footnote(
    footnote = "Manufacturer suggested retail price, USD.",
    locations = cells_column_labels(columns = msrp)
  ) |>
  tab_footnote(
    footnote = "Highest horsepower in this table.",
    locations = cells_body(columns = hp, rows = hp == max(hp))
  ) |>
  tab_footnote(
    footnote = "Measured at the crank.",
    locations = cells_column_spanners(spanners = "Performance")
  )

# Footnote marks: numbers, letters or symbols
tbl |>
  tab_footnote("Price in USD", locations = cells_column_labels(msrp)) |>
  opt_footnote_marks(marks = "letters")

# Putting it together
cars |>
  gt(rowname_col = "model", groupname_col = "ctry_origin") |>
  tab_header(title = "German and Italian sports cars") |>
  tab_stubhead("Model") |>
  cols_hide(mfr) |>
  tab_spanner("Performance", columns = c(hp, trq)) |>
  tab_spanner("Fuel economy (mpg)", columns = c(mpg_c, mpg_h)) |>
  cols_label(hp = "HP", trq = "Torque", mpg_c = "City", mpg_h = "Hwy", msrp = "Price") |>
  fmt_currency(columns = msrp, decimals = 0) |>
  summary_rows(columns = msrp, fns = list(Average = ~ mean(.)),
               fmt = ~ fmt_currency(., decimals = 0)) |>
  tab_source_note("Source: gt::gtcars")

# Try it:
# Group towny by csd_type, show name, population_2021 and density_2021
# for 3 rows per group, add a "Population" spanner over the two numbers
# and a per-group total for population_2021.
