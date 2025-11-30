# R/01_clean_reaim.R

source(file.path("R", "requirements.R"))

raw_excel_path <- file.path("data-raw", "dsg_spmifu_reaim_tables-10-22-2025.xlsx") # nolint: line_length_linter.

reaim_table <- readxl::read_excel(raw_excel_path, sheet = "reaim_table")

# ---- Clean labels and create var_name ------------------------------------
# Rename the first column to `label` and identify section/subsection rows.
section_labels <- c(
  "RE-AIM",
  "Effectiveness*",
  "Patient Factors*",
  "Comorbidity score, Charlson",
  "Utilization During Follow-up*",
  "Case management",
  "Pharmacist visits"
)

subsection_map <- list(
  `Case management` = c("Year 1", "Year 2", "Any"),
  `Pharmacist visits` = c(
    "Intake, any",
    "Return visit, any",
    "Return visit, Year 1",
    "Return visit, Year 2**"
  )
)

cleaned <- reaim_table |>
  rename(label = 1) |>
  mutate(
    label = trimws(label),
    section = if_else(label %in% section_labels, label, NA_character_)
  ) |>
  tidyr::fill(section) |>
  mutate(
    subsection = dplyr::case_when(
      section == "Case management" & label %in% subsection_map$`Case management` ~ label,
      section == "Pharmacist visits" & label %in% subsection_map$`Pharmacist visits` ~ label,
      TRUE ~ NA_character_
    )
  )

# Mapping of key rows to desired variable names.
label_map <- tibble::tribble(
  ~section, ~subsection, ~label, ~var_name,
  "RE-AIM", NA, "Reach, absolute %", "reach_abs",
  "RE-AIM", NA, "Reach, absolute % (2020-2021)", "reach_abs_2020_2021",
  "RE-AIM", NA, "Whole months in operation", "months_op",
  "Effectiveness*", NA, "Adherence at baseline", "adh_baseline",
  "Effectiveness*", NA, "Adherence at follow up Year 1", "adh_y1",
  "Effectiveness*", NA, "Adherence at follow up Year 2", "adh_y2",
  "Effectiveness*", NA, "Adherence at either Y1 or Y2", "adh_ever",
  "Patient Factors*", NA, "Medicaid insurance", "medicaid",
  "Patient Factors*", NA, "Past hospitalization", "past_hosp",
  "Comorbidity score, Charlson", NA, "Mean (SD)", "charlson_mean",
  "Case management", "Year 1", "Year 1", "case_mgmt_y1",
  "Case management", "Year 2", "Year 2", "case_mgmt_y2",
  "Case management", "Any", "Any", "case_mgmt_any",
  "Case management", NA, "Mean (SD)", "case_mgmt_mean",
  "Pharmacist visits", "Intake, any", "Intake, any", "pharm_intake_any",
  "Pharmacist visits", "Return visit, any", "Return visit, any", "pharm_return_any",
  "Pharmacist visits", "Return visit, Year 1", "Return visit, Year 1", "pharm_return_y1",
  "Pharmacist visits", "Return visit, Year 2**", "Return visit, Year 2**", "pharm_return_y2",
  "Pharmacist visits", NA, "mean (SD)", "pharm_return_mean",
  "Pharmacist visits", NA, "median (Q1-Q3)", "pharm_return_median"
)

cleaned <- cleaned |>
  left_join(label_map, by = c("section", "subsection", "label")) |>
  mutate(
    var_name = dplyr::coalesce(
      var_name,
      janitor::make_clean_names(paste(section, subsection, label, sep = "_"))
    )
  )

# Drop rows that are pure headers with no data in any site columns.
site_cols <- setdiff(names(cleaned), c("label", "section", "subsection", "var_name"))
cleaned <- cleaned |>
  filter(dplyr::if_any(dplyr::all_of(site_cols), ~ !is.na(.)))

# ---- Long format, parse values, pivot wide -------------------------------
long_tbl <- cleaned |>
  select(label, section, subsection, var_name, dplyr::all_of(site_cols)) |>
  tidyr::pivot_longer(
    cols = dplyr::all_of(site_cols),
    names_to = "site",
    values_to = "value"
  ) |>
  mutate(value_chr = as.character(value)) |>
  mutate(
    n = dplyr::if_else(
      stringr::str_detect(value_chr, "\\("),
      readr::parse_number(stringr::str_replace(value_chr, "\\s*\\(.*", "")),
      NA_real_
    ),
    pct = dplyr::if_else(
      stringr::str_detect(value_chr, "\\("),
      readr::parse_number(stringr::str_extract(value_chr, "(?<=\\().*?(?=\\))")),
      readr::parse_number(value_chr)
    )
  ) |>
  select(-value, -value_chr)

key_vars <- c(
  "reach_abs",
  "reach_abs_2020_2021",
  "months_op",
  "adh_baseline",
  "adh_y1",
  "adh_y2",
  "adh_ever",
  "medicaid",
  "past_hosp",
  "charlson_mean",
  "case_mgmt_y1",
  "case_mgmt_y2",
  "case_mgmt_any",
  "case_mgmt_mean",
  "pharm_intake_any",
  "pharm_return_any",
  "pharm_return_y1",
  "pharm_return_y2",
  "pharm_return_mean",
  "pharm_return_median"
)

site_level <- long_tbl |>
  filter(var_name %in% key_vars) |>
  select(site, var_name, pct) |>
  tidyr::pivot_wider(names_from = var_name, values_from = pct)

readr::write_csv(site_level, file.path("data", "reaim_site_level.csv"))