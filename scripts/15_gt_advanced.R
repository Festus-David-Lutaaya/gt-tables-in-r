# Lesson 15: advanced gt
# cols_nanoplot(), text_transform() with HTML, cols_label_with(),
# rows_add(), extract_cells(), building tables with functions and purrr

library(gt)
library(dplyr)
library(tidyr)
library(purrr)

# Nanoplots: small charts inside cells -------------------------------

trend <- countrypops |>
  filter(country_code_3 %in% c("UGA", "KEN", "TZA", "RWA", "BDI"),
         year >= 2000) |>
  select(country_name, year, population) |>
  pivot_wider(names_from = year, values_from = population)

trend |>
  gt(rowname_col = "country_name") |>
  cols_nanoplot(
    columns = matches("^20"),
    new_col_name = "trend",
    new_col_label = "Population 2000 onwards"
  ) |>
  tab_header(title = "East African Community populations")

# Keep the latest value as a number too
trend |>
  gt(rowname_col = "country_name") |>
  cols_nanoplot(
    columns = matches("^20"),
    plot_type = "bar",
    new_col_name = "trend",
    new_col_label = "Trend",
    autohide = FALSE
  ) |>
  cols_hide(columns = matches("^20(0|1)")) |>
  fmt_integer(columns = matches("^202"))

# Bars made with text_transform() -----------------------------------

bar_html <- function(x, max_x, colour = "#1F77B4") {
  width <- round(100 * as.numeric(x) / max_x)
  sprintf(
    '<div style="background:%s;width:%d%%;height:12px;border-radius:2px;"></div>',
    colour, width
  )
}

pizza <- pizzaplace |>
  count(type, name = "sold") |>
  mutate(bar = sold)

pizza |>
  gt() |>
  text_transform(
    locations = cells_body(columns = bar),
    fn = function(x) bar_html(x, max(pizza$sold))
  ) |>
  cols_label(type = "Type", sold = "Sold", bar = "") |>
  cols_width(bar ~ px(200))

# Labels from a function -------------------------------------------

exibble |>
  select(num, char, currency) |>
  gt() |>
  cols_label_with(fn = ~ tools::toTitleCase(.x))

# Adding rows ------------------------------------------------------

gtcars |>
  select(model, hp) |>
  slice_head(n = 4) |>
  gt() |>
  rows_add(model = "Average", hp = mean(gtcars$hp[1:4]))

# Reading values back out ------------------------------------------

t <- gtcars |> select(model, msrp) |> slice_head(n = 3) |> gt() |>
  fmt_currency(msrp, decimals = 0)
extract_cells(t, columns = msrp)

# Tables from a function -------------------------------------------
# Once a table design is settled, write it once and call it many times.

country_table <- function(code) {
  d <- countrypops |>
    filter(country_code_3 == code, year %in% seq(1980, 2020, 10)) |>
    select(year, population)

  gt(d, rowname_col = "year") |>
    tab_header(title = unique(countrypops$country_name[countrypops$country_code_3 == code])) |>
    fmt_integer(population) |>
    cols_label(population = "Population")
}

country_table("UGA")

tabs <- map(c("UGA", "KEN", "TZA"), country_table)
tabs[[2]]

# bundle and save in one file
dir.create("output", showWarnings = FALSE)
gt_group(.list = tabs) |> gtsave("output/15_country_tables.html")

# Try it:
# Write a function that takes a pizza size (S, M, L, XL, XXL) and returns
# a table of the top 5 pizza names by count for that size, with a bar column.
