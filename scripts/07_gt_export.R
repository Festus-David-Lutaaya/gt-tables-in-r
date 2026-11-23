# Lesson 7: getting tables out of R
# gtsave(), as_raw_html(), as_word(), as_rtf(), as_latex()

library(gt)
library(dplyr)

dir.create("output", showWarnings = FALSE)

tbl <- gtcars |>
  select(mfr, model, hp, msrp) |>
  slice_head(n = 8) |>
  gt(rowname_col = "model") |>
  tab_header(title = "Sports cars") |>
  fmt_currency(columns = msrp, decimals = 0)

# gtsave() picks the format from the file extension
gtsave(tbl, "output/07_cars.html")
gtsave(tbl, "output/07_cars.docx")
gtsave(tbl, "output/07_cars.rtf")
gtsave(tbl, "output/07_cars.tex")

# .png and .pdf go through a headless browser, so they need webshot2
if (requireNamespace("webshot2", quietly = TRUE)) {
  gtsave(tbl, "output/07_cars.png", expand = 10)
  gtsave(tbl, "output/07_cars.pdf")
}

# Strings instead of files
html_code <- as_raw_html(tbl)             # inline CSS, good for emails
substr(html_code, 1, 200)

html_no_css <- as_raw_html(tbl, inline_css = FALSE)

word_xml <- as_word(tbl)                  # OOXML, used inside officer docs
rtf_code <- as_rtf(tbl)
latex_code <- as_latex(tbl)               # for PDF via R Markdown / Quarto

# Embedding in Quarto / R Markdown:
# just print the gt object in a chunk. It renders as HTML in html output,
# LaTeX in pdf output and a Word table in docx output.

# Several tables into one Word file
# gt_group() bundles tables; gtsave() writes them one after another
grp <- gt_group(
  tbl,
  tbl |> tab_header(title = "Same cars, second copy")
)
gtsave(grp, "output/07_two_tables.docx")

# Long tables can be split across pages
big <- gtcars |> select(mfr, model, hp) |> gt()
pieces <- gt_split(big, row_every_n = 15)
pieces

# Try it:
# Save the pizza summary table from lesson 3 as .html and .docx,
# then open the .docx in Word and see what survived.
