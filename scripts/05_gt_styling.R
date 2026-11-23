# Lesson 5: styling cells
# tab_style(), cell_text(), cell_fill(), cell_borders(), data_color(),
# opt_row_striping(), cells_*() targets

library(gt)
library(dplyr)

cars <- gtcars |>
  select(mfr, model, hp, mpg_h, msrp) |>
  slice_head(n = 10)

tbl <- gt(cars, rowname_col = "model") |>
  fmt_currency(columns = msrp, decimals = 0)

# tab_style() = what style + where.
tbl |>
  tab_style(
    style = cell_text(weight = "bold"),
    locations = cells_column_labels()
  )

# Several styles at once go in a list
tbl |>
  tab_style(
    style = list(cell_fill(color = "#FFF3CD"), cell_text(weight = "bold")),
    locations = cells_body(rows = hp > 600)
  )

# Highlight one column
tbl |>
  tab_style(
    style = cell_text(color = "darkred"),
    locations = cells_body(columns = msrp)
  )

# Rows and columns together
tbl |>
  tab_style(
    style = cell_fill(color = "lightblue"),
    locations = cells_body(columns = hp, rows = hp == max(hp))
  )

# The stub, titles and group labels are separate locations
tbl |>
  tab_header(title = "Top 10 cars") |>
  tab_style(cell_text(size = "large", color = "navy"), cells_title(groups = "title")) |>
  tab_style(cell_text(style = "italic"), cells_stub())

# Borders
tbl |>
  tab_style(
    style = cell_borders(sides = "bottom", color = "black", weight = px(2)),
    locations = cells_column_labels()
  ) |>
  tab_style(
    style = cell_borders(sides = c("left", "right"), color = "grey80"),
    locations = cells_body(columns = hp)
  )

# Several locations in one call
tbl |>
  tab_style(
    style = cell_text(font = "Courier"),
    locations = list(cells_body(columns = msrp), cells_column_labels(columns = msrp))
  )

# Conditional colour scales with data_color()
tbl |>
  data_color(columns = hp, palette = "Blues")

tbl |>
  data_color(columns = mpg_h, palette = c("tomato", "white", "seagreen"))

# Colour a different column based on a value
tbl |>
  data_color(
    columns = msrp,
    target_columns = model,
    palette = "Oranges"
  )

# A categorical palette
tbl |>
  data_color(columns = mfr, method = "factor", palette = "Set2")

# Zebra stripes
tbl |> opt_row_striping()

# Example: flag lab values outside a reference range
labs <- tibble(
  id = sprintf("P%02d", 1:8),
  hb = c(13.1, 9.8, 14.2, 12.0, 8.9, 15.1, 11.5, 13.8),
  wbc = c(6.2, 12.4, 5.1, 3.2, 7.7, 4.8, 11.9, 6.6)
)

gt(labs, rowname_col = "id") |>
  cols_label(hb = "Hb (g/dL)", wbc = "WBC (x10^9/L)") |>
  tab_style(
    style = list(cell_fill("#F8D7DA"), cell_text(weight = "bold")),
    locations = cells_body(columns = hb, rows = hb < 11)
  ) |>
  tab_style(
    style = list(cell_fill("#F8D7DA"), cell_text(weight = "bold")),
    locations = cells_body(columns = wbc, rows = wbc < 4 | wbc > 11)
  ) |>
  tab_source_note("Shaded cells fall outside the reference range.")

# Try it:
# Using exibble, make every NA cell grey, bold the row where
# char == "banana", and add a light border under the column labels.
