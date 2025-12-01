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
  "Substance use:",
  "Utilization During Follow-up*",
  "Case management",
  "Pharmacist visits"
)

subsection_map <- list(
  `Case management` = c("Year 1", "Year 2", "Any"),
  `Substance use` = c(
    "Alcohol use disorder",
    "Drug use disorder",
    "Alcohol or drug use disorder"
  ),
  `Pharmacist visits` = c(
    "Intake, any",
    "Return visit, any",
    "Return visit, Year 1",
    "Return visit, Year 2**"
  )
)

cleaned_labels <- reaim_table |>
  rename(label = 1) |>
  mutate(
    label = trimws(label),
    section = dplyr::case_when(
      label %in% section_labels ~ label,
      stringr::str_detect(label, stringr::regex("^Substance use", ignore_case = TRUE)) ~ "Substance use",
      TRUE ~ NA_character_
    )
  ) |>
  tidyr::fill(section) |>
  mutate(
    subsection = dplyr::case_when(
      section == "Case management" & label %in% subsection_map$`Case management` ~ label,
      section == "Substance use" & label %in% subsection_map$`Substance use` ~ label,
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
  "Substance use", "Alcohol use disorder", "Alcohol use disorder", "substance_alcohol",
  "Substance use", "Drug use disorder", "Drug use disorder", "substance_drug",
  "Substance use", "Alcohol or drug use disorder", "Alcohol or drug use disorder", "substance_any",
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

mapped_rows <- cleaned_labels |>
  left_join(label_map, by = c("section", "subsection", "label")) |>
  mutate(
    var_name = dplyr::coalesce(
      var_name,
      janitor::make_clean_names(paste(section, subsection, label, sep = "_"))
    )
  )

# Keep explicit checkpoint for mapped rows.
mapped_checkpoint <- mapped_rows

# Drop rows that are pure headers with no data in any site columns.
site_cols <- setdiff(names(mapped_rows), c("label", "section", "subsection", "var_name"))
cleaned <- mapped_rows |>
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
    has_paren = stringr::str_detect(value_chr, "\\("),
    row_type = dplyr::case_when(
      stringr::str_detect(var_name, "mean$") |
        stringr::str_detect(label, stringr::regex("^mean", ignore_case = TRUE)) ~ "mean",
      stringr::str_detect(var_name, "median$") |
        stringr::str_detect(label, stringr::regex("^median", ignore_case = TRUE)) ~ "median",
      TRUE ~ "count_pct"
    ),
    count = dplyr::if_else(
      row_type == "count_pct" & has_paren,
      readr::parse_number(stringr::str_replace(value_chr, "\\s*\\(.*", "")),
      NA_real_
    ),
    pct = dplyr::case_when(
      row_type == "count_pct" & has_paren ~ round(
        readr::parse_number(stringr::str_extract(value_chr, "(?<=\\().*?(?=\\))")),
        digits = 1
      ),
      row_type == "count_pct" & !has_paren ~ round(
        readr::parse_number(value_chr),
        digits = 1
      ),
      TRUE ~ NA_real_
    ),
    mean = dplyr::if_else(
      row_type == "mean",
      readr::parse_number(stringr::str_replace(value_chr, "\\s*\\(.*", "")),
      NA_real_
    ),
    sd = dplyr::if_else(
      row_type == "mean",
      readr::parse_number(stringr::str_extract(value_chr, "(?<=\\().*?(?=\\))")),
      NA_real_
    ),
    median = dplyr::if_else(
      row_type == "median",
      readr::parse_number(stringr::str_replace(value_chr, "\\s*\\(.*", "")),
      NA_real_
    ),
    q1 = dplyr::if_else(
      row_type == "median",
      readr::parse_number(stringr::str_extract(value_chr, "(?<=\\().*?(?=-)")),
      NA_real_
    ),
    q3 = dplyr::if_else(
      row_type == "median",
      readr::parse_number(stringr::str_extract(value_chr, "(?<=-).*(?=\\))")),
      NA_real_
    )
  ) |>
  select(-value, -value_chr, -has_paren)

# Parsed components checkpoint.
parsed_components <- long_tbl

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
  "substance_alcohol",
  "substance_drug",
  "substance_any",
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

site_components <- long_tbl |>
  filter(var_name %in% key_vars) |>
  mutate(
    # Restrict components to relevant row types to avoid spurious all-NA columns.
    count = dplyr::if_else(row_type == "count_pct", count, NA_real_),
    pct = dplyr::if_else(row_type == "count_pct", pct, NA_real_),
    mean = dplyr::if_else(row_type == "mean", mean, NA_real_),
    sd = dplyr::if_else(row_type == "mean", sd, NA_real_),
    median = dplyr::if_else(row_type == "median", median, NA_real_),
    q1 = dplyr::if_else(row_type == "median", q1, NA_real_),
    q3 = dplyr::if_else(row_type == "median", q3, NA_real_)
  ) |>
  select(
    site,
    var_name,
    count,
    pct,
    mean,
    sd,
    median,
    q1,
    q3
  )

site_components_long <- site_components |>
  tidyr::pivot_longer(
    cols = c(count, pct, mean, sd, median, q1, q3),
    names_to = "component",
    values_to = "value"
  )

site_level <- site_components_long |>
  # Drop empty component rows to avoid creating all-NA columns downstream.
  dplyr::filter(!is.na(value)) |>
  tidyr::pivot_wider(
    names_from = c("var_name", "component"),
    values_from = value,
    names_glue = "{var_name}_{component}"
  )

readr::write_csv(site_level, file.path("data", "reaim_site_level.csv"))
