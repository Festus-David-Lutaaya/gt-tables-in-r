# Lesson 17 (clinical 2): adverse event tables
# Two ways: build it yourself with dplyr + gt, then with tbl_hierarchical()

library(gt)
library(gtsummary)
library(dplyr)
library(tidyr)

source("R/clinical_data.R")
head(adae)

big_n <- adsl |> count(ARM, name = "N")
big_n

# The dplyr + gt way ---------------------------------------------------
# Count subjects, not events: a subject with two headaches counts once.

subj_counts <- adae |>
  distinct(USUBJID, ARM, AEBODSYS, AEDECOD) |>
  count(ARM, AEBODSYS, AEDECOD) |>
  left_join(big_n, by = "ARM") |>
  mutate(pct = n / N)

soc_counts <- adae |>
  distinct(USUBJID, ARM, AEBODSYS) |>
  count(ARM, AEBODSYS) |>
  left_join(big_n, by = "ARM") |>
  mutate(pct = n / N, AEDECOD = "Any event")

ae_long <- bind_rows(soc_counts, subj_counts) |>
  mutate(cell = sprintf("%d (%.1f%%)", n, 100 * pct))

ae_wide <- ae_long |>
  select(AEBODSYS, AEDECOD, ARM, cell) |>
  pivot_wider(names_from = ARM, values_from = cell, values_fill = "0") |>
  arrange(AEBODSYS, AEDECOD != "Any event", AEDECOD)

col_labels <- setNames(
  sprintf("%s<br>N = %d", big_n$ARM, big_n$N),
  as.character(big_n$ARM)
)

ae_gt <- ae_wide |>
  gt(rowname_col = "AEDECOD", groupname_col = "AEBODSYS") |>
  cols_label(.list = lapply(col_labels, html)) |>
  cols_align("center", columns = -c(AEBODSYS, AEDECOD)) |>
  tab_stubhead("System organ class / Preferred term") |>
  tab_style(
    style = cell_text(weight = "bold"),
    locations = list(cells_row_groups(), cells_stub(rows = AEDECOD == "Any event"))
  ) |>
  tab_style(
    style = cell_text(indent = px(15)),
    locations = cells_stub(rows = AEDECOD != "Any event")
  ) |>
  tab_header(
    title = "Table 14.3.1 Treatment-emergent adverse events by SOC and PT",
    subtitle = "Safety population"
  ) |>
  tab_source_note("Subjects are counted once per SOC and once per PT. n (%).") |>
  opt_align_table_header("left")

ae_gt

# Highlight terms that are at least 10 points higher on 20 mg than placebo
diff_terms <- subj_counts |>
  select(ARM, AEDECOD, pct) |>
  pivot_wider(names_from = ARM, values_from = pct, values_fill = 0) |>
  filter(`Drug 20 mg` - Placebo >= 0.10) |>
  pull(AEDECOD)

ae_gt |>
  tab_style(
    style = cell_fill(color = "#FDECEA"),
    locations = cells_body(rows = AEDECOD %in% diff_terms)
  ) |>
  tab_footnote("Shaded: incidence on 20 mg at least 10 percentage points above placebo.")

# Overview table: any AE, serious, severe --------------------------------

overview <- adsl |>
  select(USUBJID, ARM) |>
  left_join(
    adae |>
      group_by(USUBJID) |>
      summarise(
        any_ae = TRUE,
        any_sae = any(AESER == "Y"),
        any_severe = any(AESEV == "Severe"),
        .groups = "drop"
      ),
    by = "USUBJID"
  ) |>
  mutate(across(starts_with("any_"), ~ coalesce(.x, FALSE)))

overview |>
  tbl_summary(
    by = ARM,
    include = starts_with("any_"),
    label = list(
      any_ae ~ "Any adverse event",
      any_sae ~ "Any serious adverse event",
      any_severe ~ "Any severe adverse event"
    )
  ) |>
  modify_header(label ~ "", all_stat_cols() ~ "**{level}**  \nN = {n}") |>
  as_gt() |>
  tab_header(title = "Table 14.3.0 Overview of adverse events")

# The gtsummary way: tbl_hierarchical() ---------------------------------

adae |>
  tbl_hierarchical(
    variables = c(AEBODSYS, AEDECOD),
    by = ARM,
    id = USUBJID,
    denominator = adsl,
    overall_row = TRUE,
    label = list(..ard_hierarchical_overall.. = "Any adverse event")
  ) |>
  as_gt() |>
  tab_header(title = "TEAEs by SOC and PT (tbl_hierarchical)")

# Worst severity per subject and term
adae |>
  tbl_hierarchical(
    variables = c(AEBODSYS, AEDECOD, AESEV),
    by = ARM,
    id = USUBJID,
    denominator = adsl,
    include = AESEV
  )

# Try it:
# Restrict to serious events (AESER == "Y") and rebuild the SOC/PT table
# with the dplyr + gt approach.
