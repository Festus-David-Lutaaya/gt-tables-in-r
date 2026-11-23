# Lesson 6: table-wide options and your own theme
# tab_options(), opt_*() helpers, opt_stylize(), writing a theme function

library(gt)
library(dplyr)

tbl <- gtcars |>
  select(mfr, model, hp, msrp) |>
  slice_head(n = 8) |>
  gt(rowname_col = "model") |>
  tab_header(title = "Sports cars", subtitle = "A small sample") |>
  fmt_currency(columns = msrp, decimals = 0) |>
  tab_source_note("Source: gt::gtcars")

# The opt_*() helpers are quick one-liners
tbl |> opt_align_table_header(align = "left")
tbl |> opt_all_caps()
tbl |> opt_table_font(font = google_font("Lato"))
tbl |> opt_table_font(font = c("Arial", default_fonts()))
tbl |> opt_vertical_padding(scale = 0.5)
tbl |> opt_horizontal_padding(scale = 2)
tbl |> opt_table_lines(extent = "none")
tbl |> opt_table_outline()

# Ready-made styles: 6 styles x several colours
tbl |> opt_stylize(style = 1, color = "blue")
tbl |> opt_stylize(style = 6, color = "gray")

# tab_options() controls everything else. There are many arguments,
# grouped by prefix: table_*, heading_*, column_labels_*, row_group_*,
# stub_*, data_row_*, footnotes_*, source_notes_*, ...
tbl |>
  tab_options(
    table.width = pct(80),
    table.font.size = px(13),
    heading.title.font.size = px(18),
    heading.background.color = "#1F4E79",
    column_labels.font.weight = "bold",
    column_labels.background.color = "#D9E2F3",
    data_row.padding = px(4),
    source_notes.font.size = px(11)
  )

# Journal style: no vertical lines, thin top/bottom rules
tbl |>
  tab_options(
    table.border.top.color = "black",
    table.border.top.width = px(2),
    table.border.bottom.color = "black",
    table.border.bottom.width = px(2),
    column_labels.border.bottom.color = "black",
    column_labels.border.bottom.width = px(1),
    table_body.hlines.color = "white",
    heading.border.bottom.color = "white"
  )

# Wrap the settings you like into a function and reuse it.
theme_lab <- function(data) {
  data |>
    opt_table_font(font = c("Arial", default_fonts())) |>
    opt_align_table_header(align = "left") |>
    tab_options(
      table.font.size = px(13),
      heading.title.font.weight = "bold",
      column_labels.font.weight = "bold",
      column_labels.background.color = "#EEF2F7",
      row_group.font.weight = "bold",
      table.border.top.color = "#1F4E79",
      table.border.top.width = px(3),
      data_row.padding = px(5)
    )
}

tbl |> theme_lab()

# it works on any gt table
countrypops |>
  filter(country_code_3 %in% c("UGA", "KEN", "TZA"), year == 2020) |>
  select(country_name, population) |>
  gt() |>
  tab_header(title = "East Africa, 2020") |>
  fmt_integer(population) |>
  theme_lab()

# Try it:
# Write theme_dark_header() that gives a dark blue heading with white
# text and stripes the rows. Apply it to two different tables.
