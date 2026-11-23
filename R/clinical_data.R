# Simulated trial data used by the clinical lessons (16-19).
# Loosely follows CDISC ADaM naming: adsl = one row per subject,
# adae = one row per adverse event.

library(dplyr)

set.seed(2026)

n <- 240

adsl <- tibble(
  USUBJID = sprintf("STUDY-%03d", 1:n),
  ARM = factor(sample(c("Placebo", "Drug 10 mg", "Drug 20 mg"), n, replace = TRUE),
               levels = c("Placebo", "Drug 10 mg", "Drug 20 mg")),
  SITE = sample(c("Kampala", "Gulu", "Mbarara", "Mbale"), n, replace = TRUE,
                prob = c(0.4, 0.2, 0.2, 0.2)),
  AGE = round(rnorm(n, 42, 13)),
  SEX = sample(c("Female", "Male"), n, replace = TRUE),
  WEIGHT = round(rnorm(n, 66, 11), 1),
  HEIGHT = round(rnorm(n, 165, 9), 1),
  HIV = sample(c("Negative", "Positive"), n, replace = TRUE, prob = c(0.85, 0.15)),
  BASE_VL = round(rlnorm(n, 8, 1.2))
) |>
  mutate(
    AGE = pmax(AGE, 18),
    BMI = round(WEIGHT / (HEIGHT / 100)^2, 1),
    AGEGR1 = cut(AGE, c(-Inf, 34, 49, Inf), labels = c("18-34", "35-49", "50+")),
    # a few missing values so the tables have something to report
    WEIGHT = replace(WEIGHT, sample(n, 6), NA),
    BMI = ifelse(is.na(WEIGHT), NA, BMI)
  )

# outcomes: response at week 12 and time to clinical failure
eff <- c("Placebo" = 0, "Drug 10 mg" = 0.6, "Drug 20 mg" = 1.0)
adsl <- adsl |>
  mutate(
    lp = -0.4 + eff[as.character(ARM)] - 0.01 * (AGE - 42) - 0.3 * (HIV == "Positive"),
    RESPONSE = rbinom(n, 1, plogis(lp)),
    TTE = round(rexp(n, rate = 0.02 * exp(-0.5 * eff[as.character(ARM)])), 1),
    CNSR = as.integer(TTE > 52),
    TTE = pmin(TTE, 52)
  ) |>
  select(-lp)

# adverse events
ae_terms <- tribble(
  ~AEBODSYS,                                ~AEDECOD,     ~rate,
  "Gastrointestinal disorders",              "Nausea",       0.18,
  "Gastrointestinal disorders",              "Diarrhoea",    0.12,
  "Gastrointestinal disorders",              "Vomiting",     0.06,
  "Nervous system disorders",                "Headache",     0.20,
  "Nervous system disorders",                "Dizziness",    0.08,
  "Skin and subcutaneous tissue disorders",  "Rash",         0.07,
  "Skin and subcutaneous tissue disorders",  "Pruritus",     0.05,
  "General disorders",                       "Fatigue",      0.15,
  "General disorders",                       "Pyrexia",      0.09,
  "Investigations",                          "ALT increased", 0.04
)

dose_mult <- c("Placebo" = 1, "Drug 10 mg" = 1.4, "Drug 20 mg" = 1.9)

adae <- adsl |>
  select(USUBJID, ARM) |>
  cross_join(ae_terms) |>
  filter(runif(n()) < rate * dose_mult[as.character(ARM)]) |>
  mutate(
    AESEV = factor(sample(c("Mild", "Moderate", "Severe"), n(), replace = TRUE,
                          prob = c(0.6, 0.3, 0.1)),
                   levels = c("Mild", "Moderate", "Severe")),
    AESER = ifelse(AESEV == "Severe" & runif(n()) < 0.4, "Y", "N")
  ) |>
  select(-rate)

rm(n, eff, ae_terms, dose_mult)
