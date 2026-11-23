# Lesson 19 (clinical 4): submission-style titles, footnotes and output
# A reusable "TLF shell" function, then HTML, Word and RTF output.

library(gtsummary)
library(gt)
library(dplyr)

source("R/clinical_data.R")
dir.create("output", showWarnings = FALSE)

# Most sponsors want the same frame around every table:
# table number, title, population, footnotes, program name and run date.

tlf_shell <- function(tbl, number, title, population,
                      footnotes = character(), program = "t_unknown.R") {
  if (inherits(tbl, "gtsummary")) tbl <- as_gt(tbl)

  out <- tbl |>
    tab_header(
      title = paste("Table", number, title),
      subtitle = population
    )

  for (f in footnotes) out <- tab_source_note(out, f)

  out |>
    tab_source_note(
      sprintf("Program: %s | Run: %s", program, format(Sys.time(), "%d%b%Y %H:%M"))
    ) |>
    opt_table_font(font = c("Courier New", "monospace")) |>
    opt_align_table_header("left") |>
    tab_options(
      table.font.size = px(11),
      heading.title.font.size = px(12),
      heading.subtitle.font.size = px(11),
      heading.title.font.weight = "bold",
      table.border.top.color = "black",
      table.border.bottom.color = "black",
      column_labels.border.top.color = "black",
      column_labels.border.bottom.color = "black",
      table_body.hlines.color = "transparent",
      source_notes.font.size = px(10),
      data_row.padding = px(1)
    )
}

# Table 14.1.1: demographics
t_demo <- adsl |>
  tbl_summary(
    by = ARM,
    include = c(AGE, SEX, BMI, HIV),
    label = list(AGE ~ "Age, years", SEX ~ "Sex", BMI ~ "BMI, kg/m²", HIV ~ "HIV status"),
    statistic = all_continuous() ~ "{mean} ({sd})"
  ) |>
  add_overall() |>
  modify_header(label ~ "", all_stat_cols() ~ "{level}<br>N = {n}") |>
  remove_footnote_header(columns = all_stat_cols()) |>
  tlf_shell(
    number = "14.1.1",
    title = "Demographic characteristics",
    population = "Safety population",
    footnotes = c("Continuous: mean (SD). Categorical: n (%).",
                  "BMI calculated from baseline weight and height."),
    program = "t_demo.R"
  )

t_demo

# Table 14.2.1: response rates with 95% CI
t_resp <- adsl |>
  mutate(RESPONSE = factor(RESPONSE, 0:1, c("No", "Yes"))) |>
  tbl_summary(
    by = ARM,
    include = RESPONSE,
    type = RESPONSE ~ "dichotomous",
    value = RESPONSE ~ "Yes",
    label = RESPONSE ~ "Responders at week 12"
  ) |>
  add_ci(pattern = "{stat} [{ci}]") |>
  modify_header(label ~ "", all_stat_cols() ~ "{level}<br>N = {n}") |>
  tlf_shell(
    number = "14.2.1",
    title = "Week 12 response",
    population = "Intent-to-treat population",
    footnotes = "n (%) [95% CI, Wilson].",
    program = "t_resp.R"
  )

t_resp

# Writing out ------------------------------------------------------

gtsave(t_demo, "output/t_14_1_1_demo.html")
gtsave(t_demo, "output/t_14_1_1_demo.docx")
gtsave(t_demo, "output/t_14_1_1_demo.rtf")      # RTF is still common in submissions

# all tables in one Word file
gt_group(t_demo, t_resp) |>
  gtsave("output/tlf_bundle.docx")

# PDF: either gtsave(..., "x.pdf") with webshot2 installed,
# or render a Quarto document to PDF and print the gt objects inside it.
if (requireNamespace("webshot2", quietly = TRUE)) {
  gtsave(t_demo, "output/t_14_1_1_demo.pdf")
}

# Word with landscape pages or a company template:
# use as_flex_table() on the gtsummary object and the officer package.
#
# library(officer); library(flextable)
# doc <- read_docx("template.docx") |>
#   body_add_flextable(as_flex_table(some_gtsummary_table))
# print(doc, target = "output/report.docx")

# Try it:
# Add a third table (the AE overview from lesson 17) to the bundle
# using tlf_shell(), then save it as both .docx and .rtf.
