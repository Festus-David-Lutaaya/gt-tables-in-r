# gt tables in R

Lesson scripts for building publication and clinical tables in R with
**gt**, using **gtsummary** to compute the statistics.

The focus is gt. gtsummary comes in after you can already build and style
a table by hand, because every gtsummary table ends up as a gt table and
the polishing is done with gt.

## Learning order

| # | Script | What you learn |
|---|--------|----------------|
| 00 | `00_setup.R` | packages, datasets |
| **Part 1: gt from scratch** | | |
| 01 | `01_gt_first_table.R` | `gt()`, `gt_preview()`, header, caption, source notes, stub |
| 02 | `02_gt_columns.R` | `cols_label()`, move, hide, align, width, merge, units |
| 03 | `03_gt_formatting.R` | `fmt_*()`, `sub_missing()`, `fmt()`, `text_transform()` |
| 04 | `04_gt_structure.R` | row groups, spanners, summary rows, footnotes, `cells_*()` |
| 05 | `05_gt_styling.R` | `tab_style()`, `cell_*()`, `data_color()` |
| 06 | `06_gt_options_themes.R` | `tab_options()`, `opt_*()`, writing a theme function |
| 07 | `07_gt_export.R` | `gtsave()`, `as_raw_html()`, Word, RTF, LaTeX, `gt_group()` |
| **Part 2: gtsummary as the stats engine** | | |
| 08 | `08_tbl_summary_basics.R` | `tbl_summary()` arguments, selectors |
| 09 | `09_add_and_modify.R` | `add_*()`, `bold_*()`, `modify_*()`, `show_header_names()` |
| 10 | `10_cross_continuous_add_stat.R` | `tbl_cross()`, `tbl_continuous()`, `add_stat()`, custom summaries |
| 11 | `11_regression_tables.R` | `tbl_regression()`, `tbl_uvregression()`, global p, stars |
| 12 | `12_merge_stack_strata.R` | `tbl_merge()`, `tbl_stack()`, `tbl_strata()` |
| 13 | `13_themes_inline_text.R` | gtsummary themes, `inline_text()` |
| **Part 3: putting them together** | | |
| 14 | `14_gtsummary_to_gt.R` | `as_gt()` then gt styling, `as_flex_table()`, `as_kable()` |
| 15 | `15_gt_advanced.R` | nanoplots, HTML in cells, table functions, `purrr` |
| **Part 4: clinical case studies** | | |
| 16 | `16_clinical_table1.R` | demographics / baseline table |
| 17 | `17_clinical_adverse_events.R` | AE tables by SOC/PT, by hand and with `tbl_hierarchical()` |
| 18 | `18_clinical_regression_subgroups.R` | efficacy models, subgroup table with forest plot |
| 19 | `19_clinical_reporting_output.R` | TLF shell function, HTML / Word / RTF output |

The clinical lessons use simulated data from `R/clinical_data.R`.

### Why this order

The original notes went gtsummary first (lessons 01-14) and only then
started gt (15-21). That works if you only ever use gtsummary defaults,
but the moment you need to change a header, shade a row or match a
journal style you are in gt anyway, without the basics.

So here:

1. gt first, on plain data frames, so you see what each function does.
2. gtsummary second, knowing that its output is something you can finish.
3. The bridge (`as_gt()`), where most real work happens.
4. Clinical tables last, since they use all of the above.

Mapping from the old numbering, if you have those notes:

| old | new |
|-----|-----|
| 15 gt basics | 01 |
| 16 cols | 02 |
| 17 fmt | 03 |
| 18 structure | 04 |
| 19 styling | 05 |
| 20 options | 06 |
| 21 export | 07 |
| 01-03 tbl_summary, arguments | 08 |
| 04, 06-08, 11-12 selectors, add_*, modify, bold | 09 |
| 05 tbl_continuous / tbl_cross | 10 |
| 09 regression | 11 |
| 10 merge / stack / strata | 12 |
| 13 themes, inline_text | 13 |
| 14, 22 as_gt and friends | 14 |
| 23 integration 2 | 14, 15 |
| 24-29 clinical | 16-19 |

## How to use

Open `gt-tables-in-r.Rproj` in RStudio so paths work from the project
root, run `scripts/00_setup.R` once, then go through the lessons line by
line. Each one ends with a short "Try it" exercise.

Files that the scripts save go to `output/` (not tracked by git).

PNG and PDF export through `gtsave()` needs `webshot2`.
