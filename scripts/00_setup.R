# Run this once before starting the lessons.

pkgs <- c("gt", "gtsummary", "dplyr", "tidyr", "purrr", "tibble",
          "survival", "broom.helpers", "cardx", "flextable")

missing <- pkgs[!pkgs %in% rownames(installed.packages())]
if (length(missing) > 0) install.packages(missing)

# optional extras:
#   webshot2  -> gtsave() to .png / .pdf
#   huxtable  -> as_hux_table()
# install.packages(c("webshot2", "huxtable"))

library(gt)
library(gtsummary)

packageVersion("gt")
packageVersion("gtsummary")

# every lesson writes its files here
dir.create("output", showWarnings = FALSE)

# datasets we lean on throughout
# gt:        exibble, gtcars, countrypops, sp500, pizzaplace, towny
# gtsummary: trial
head(exibble)
head(trial)
