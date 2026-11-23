# Lesson 2: working with columns
# cols_label(), cols_move*(), cols_hide(), cols_align(), cols_width(),
# cols_merge(), cols_units(), cols_add()

library(gt)
library(dplyr)

cars <- gtcars |>
  select(mfr, model, year, hp, hp_rpm, trq, mpg_c, mpg_h, msrp) |>
  slice_head(n = 8)

tbl <- gt(cars, rowname_col = "model")

# Relabel columns. Names on the left are the real column names.
tbl |>
  cols_label(
    mfr = "Maker",
    year = "Year",
    hp = "Horsepower",
    msrp = "Price"
  )

# Labels accept md() and html() too
tbl |>
  cols_label(
    hp = md("**HP**"),
    mpg_c = html("MPG<br>city"),
    mpg_h = html("MPG<br>hwy")
  )

# Units: cols_units() appends unit notation to the label
tbl |>
  cols_label(hp = "Power", trq = "Torque") |>
  cols_units(hp = "hp", trq = "lb-ft")

# Re-order columns
tbl |> cols_move_to_start(columns = msrp)
tbl |> cols_move_to_end(columns = mfr)
tbl |> cols_move(columns = c(mpg_c, mpg_h), after = year)

# Hide columns you still need for calculations but not for display
tbl |> cols_hide(columns = c(hp_rpm, trq))

# Alignment
tbl |>
  cols_align(align = "center", columns = year) |>
  cols_align(align = "left", columns = mfr)

# Widths, in px() or pct()
tbl |>
  cols_width(
    mfr ~ px(120),
    everything() ~ px(80)
  )

# Merging columns. The pattern uses {1}, {2} for the columns, in order.
tbl |>
  cols_merge(columns = c(mpg_c, mpg_h), pattern = "{1} / {2}") |>
  cols_label(mpg_c = "MPG (city / hwy)")

tbl |>
  cols_merge(columns = c(hp, hp_rpm), pattern = "{1} @ {2} rpm") |>
  cols_label(hp = "Power")

# Value with uncertainty: cols_merge_uncert()
lab <- tibble(
  analyte = c("Glucose", "ALT", "Creatinine"),
  mean = c(5.4, 32.1, 78.2),
  sd = c(0.6, 8.4, 11.9)
)

gt(lab) |>
  cols_merge_uncert(col_val = mean, col_uncert = sd) |>
  cols_label(analyte = "Analyte", mean = "Mean ± SD")

# Ranges: cols_merge_range()
gt(tibble(group = c("A", "B"), low = c(12, 20), high = c(18, 31))) |>
  cols_merge_range(col_begin = low, col_end = high) |>
  cols_label(low = "Range")

# Add a computed column directly in the gt object
tbl |>
  cols_add(hp_per_1k = hp / (msrp / 1000), .after = msrp) |>
  cols_label(hp_per_1k = "HP per $1k")

# Selecting columns: everything you learned from dplyr works here
tbl |> cols_hide(columns = starts_with("mpg"))
tbl |> cols_align("right", columns = where(is.numeric))

# Try it:
# From gtcars, show mfr, model, mpg_c and mpg_h, merge the two mpg
# columns as "city / hwy", hide nothing, and centre the merged column.
