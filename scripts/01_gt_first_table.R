# Lesson 1: your first gt table
# gt(), gt_preview(), tab_header(), tab_caption(), tab_source_note()

library(gt)
library(dplyr)

# A gt table always starts from a data frame.
exibble

gt(exibble)

# For big data frames, gt_preview() shows the top and bottom rows only
gt_preview(gtcars)
gt_preview(gtcars, top_n = 3, bottom_n = 2)

# Work with a small subset for now
cars <- gtcars |>
  select(mfr, model, year, hp, msrp) |>
  slice_head(n = 8)

tbl <- gt(cars)
tbl

# Titles go in the header
tbl |>
  tab_header(title = "Selected sports cars")

tbl |>
  tab_header(
    title = "Selected sports cars",
    subtitle = "Horsepower and price, from the gtcars dataset"
  )

# md() and html() let you style the text yourself
tbl |>
  tab_header(
    title = md("**Selected** sports cars"),
    subtitle = html("<em>source:</em> gtcars")
  )

# A caption sits above the table (useful in R Markdown / Quarto for numbering)
tbl |>
  tab_caption("Table 1. Sports cars by manufacturer")

# Source notes sit at the bottom. You can add more than one.
tbl |>
  tab_header(title = "Selected sports cars") |>
  tab_source_note("Data: gtcars, from the gt package") |>
  tab_source_note(md("Prices are *MSRP* in USD"))

# rowname_col turns a column into the stub (row labels on the left)
gt(cars, rowname_col = "model")

# groupname_col groups rows by a column
gt(cars, rowname_col = "model", groupname_col = "mfr")

# Try it:
# 1. Build a table of the first 10 rows of countrypops for Uganda
#    (country_name == "Uganda") with a title and a source note.
# 2. Make 'year' the stub.

countrypops |>
  filter(country_name == "Uganda") |>
  slice_tail(n = 10) |>
  select(year, population) |>
  gt(rowname_col = "year") |>
  tab_header(title = "Uganda population, last 10 years") |>
  tab_source_note("Source: World Bank via gt::countrypops")
