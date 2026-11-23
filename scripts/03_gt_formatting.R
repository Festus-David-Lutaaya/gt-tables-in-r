# Lesson 3: formatting cell values
# fmt_number(), fmt_integer(), fmt_percent(), fmt_currency(), fmt_scientific(),
# fmt_date(), fmt_datetime(), sub_missing(), sub_zero(), fmt(), text_transform()

library(gt)
library(dplyr)

# The fmt_*() functions change how values look, not the values themselves.
exibble

# Numbers
exibble |>
  gt() |>
  fmt_number(columns = num, decimals = 2)

exibble |>
  gt() |>
  fmt_number(columns = num, decimals = 1, suffixing = TRUE)   # 1.2K, 3.4M

exibble |>
  gt() |>
  fmt_number(columns = num, decimals = 0, sep_mark = " ")

# Integers
countrypops |>
  filter(country_code_3 == "UGA", year >= 2015) |>
  select(year, population) |>
  gt() |>
  fmt_integer(columns = population)

# Percentages. Values should be proportions (0.25 -> 25%)
tibble(group = c("A", "B", "C"), prop = c(0.123, 0.5, 0.0456)) |>
  gt() |>
  fmt_percent(columns = prop, decimals = 1)

# Currency
exibble |>
  gt() |>
  fmt_currency(columns = currency, currency = "USD")

exibble |>
  gt() |>
  fmt_currency(columns = currency, currency = "UGX", decimals = 0)

# Scientific notation, handy for p-values and concentrations
tibble(gene = c("BRCA1", "TP53", "EGFR"), p = c(3.2e-8, 0.00041, 0.032)) |>
  gt() |>
  fmt_scientific(columns = p, decimals = 2)

# Dates and times
exibble |>
  gt() |>
  fmt_date(columns = date, date_style = "day_month_year") |>
  fmt_time(columns = time, time_style = "h_m_p")

info_date_style()   # all the date styles

# Missing values
exibble |>
  gt() |>
  sub_missing(missing_text = "-")

# Formatting only some rows
exibble |>
  gt() |>
  fmt_number(columns = num, rows = num > 100, decimals = 0) |>
  fmt_number(columns = num, rows = num <= 100, decimals = 3)

# Locale changes separators and currency style together
exibble |>
  gt() |>
  fmt_number(columns = num, decimals = 2, locale = "fr")

# Text: markdown in cells
tibble(item = c("**bold**", "*italic*", "`code`")) |>
  gt() |>
  fmt_markdown(columns = item)

# Your own formatter with fmt()
tibble(p = c(0.2, 0.04, 0.0003)) |>
  gt() |>
  fmt(columns = p, fns = function(x) {
    ifelse(x < 0.001, "<0.001", formatC(x, format = "f", digits = 3))
  })

# text_transform() works on the already formatted text
exibble |>
  select(char) |>
  gt() |>
  text_transform(
    locations = cells_body(columns = char),
    fn = function(x) toupper(x)
  )

# A realistic example: sales summary from pizzaplace
pizza <- pizzaplace |>
  group_by(type) |>
  summarise(n = n(), revenue = sum(price), .groups = "drop") |>
  mutate(share = revenue / sum(revenue))

pizza |>
  gt(rowname_col = "type") |>
  tab_header(title = "Pizza sales by type, 2015") |>
  cols_label(n = "Pizzas sold", revenue = "Revenue", share = "Share") |>
  fmt_integer(columns = n) |>
  fmt_currency(columns = revenue, decimals = 0) |>
  fmt_percent(columns = share, decimals = 1)

# Try it:
# Using sp500, take the first 10 rows, format date as "month_day_year",
# open/high/low/close as currency, and volume with suffixing.
