# RE-AIM Site Insights

This summary synthesizes findings from `analysis_reaim.R` using `data/reaim_site_level.csv`. Figures are in `figures/`, tables in `tables/`.

## Key Patterns
- Reach: Napa Solano leads reach (48.7%), while South Sacramento (7.3%) and Santa Rosa (8.1%) lag sharply despite reasonable monthly velocity (South Sacramento enrolls ~41 pts/month over its short run). San Jose and Napa Solano show the highest monthly enrollment pace (~49/month).
- Reach vs time in operation: Younger programs (Santa Rosa, South Sacramento) have low cumulative reach but competitive monthly velocity; see `figures/reach_age_vs_velocity.png` which sizes points by reach % and labels program age.
- Adherence: Adherence is consistently high across sites (70–78%). South San Francisco tops at 78.4%; Napa Solano trails at 69.9% and shows the steepest drop by Year 2 (Y2/Y1 ~0.92). Santa Rosa is the only site with Year 2 improvement (Y2/Y1 ~1.02).
- Workforce intensity: Case management intensity varies threefold (Fresno mean 9 vs. South Sacramento 2.9). IQR is tight for San Jose (2–6) but wide for Fresno (0–12) and South San Francisco (1–12), signaling uneven workload distribution (see `figures/case_management_intensity_iqr.png`; data in `tables/case_management_summary.csv`). Pharmacist follow-ups range from 4 (Napa Solano) to 7.7 (San Rafael), suggesting divergent staffing or workflows.
- Substance use vs case management: Across sites the correlation is essentially flat (r ≈ -0.04), meaning higher SUD burden is not consistently paired with more case management. South San Francisco and Fresno deliver higher CM than expected at their SUD levels; Napa Solano lags given its SUD mix (see `figures/substance_case_management.png`).
- Medicaid: Mix ranges from 0–36%; South Sacramento and Napa Solano have the highest shares, Fresno reports 0% (data flag). Medicaid vs reach/adherence plots show South Sacramento under-reaching its high-Medicaid population, while South San Francisco sustains high adherence despite moderate Medicaid (see `figures/medicaid_by_site.png`, `figures/medicaid_vs_outcomes.png`; summary in `tables/medicaid_summary.csv`). Fresno* is asterisked on Medicaid-related plots to flag potential data error.
- Clusters: Cluster scatter (`figures/cluster_scatter.png`) shows Cluster 1 (high reach, high Medicaid) offset by lower adherence; Cluster 2 (mid reach, high adherence, higher pharmacy) and Cluster 3 (lower reach, high adherence, higher CM) occupy distinct regions, with point size denoting Medicaid mix.
- Population mix: Medicaid share ranges from 0% (Fresno, likely data issue) and 2% (Central Valley) up to 36% (South Sacramento) and 31% (Napa Solano). Substance use diagnosis burden is highest in South San Francisco (17.2%) and Napa Solano (13.6%).

## Meaningful Contradictions
- Napa Solano: Highest reach and high Medicaid (31%) but lowest adherence (69.9%) and lowest pharmacist returns (4). Substance use burden is second highest; indicates possible need for more pharmacy or SUD support.
- South Sacramento: Highest Medicaid share (35.8%) but lowest reach (7.3%) and lean case management (2.9). Despite this, adherence holds at 72.4%; suggests access or referral barriers rather than care quality.
- South San Francisco: High adherence (78.4%) despite high substance burden (17.2%) and only moderate pharmacy intensity; could hold successful SUD-sensitive workflows worth spreading.
- Fresno: Reports 0% Medicaid yet high case management (9) and moderate adherence (72.4%); data anomaly plus operational question on payer mix and outreach focus.
- San Rafael: Highest pharmacist follow-ups (7.7) but only mid-pack reach (32.1%); potential to pair strong pharmacy model with broader outreach.

## Site Profiles (clusters)
- **Profile A – High Reach / High Medicaid, Lean Support (Napa Solano; South Sacramento):** Fast enrollment, large Medicaid share, but lower adherence and modest pharmacy intensity. Hypothesis: rapid ramp-up outpaced longitudinal support and pharmacy capacity, especially for complex patients.
- **Profile B – High Adherence with Pharmacy Strength (San Jose; San Rafael; Santa Rosa):** Moderate reach, strong adherence (76–78%), higher pharmacy follow-up (5.5–7.7). Likely benefits from pharmacist-driven maintenance and stable workflows.
- **Profile C – Low Medicaid / High Case Mgmt (Central Valley; South San Francisco; Fresno):** Lower reach percentage but strong adherence (72–78%) with intensive case management (7–9). Possibly commercial/Medicare-heavy panels with proactive care managers; examine sustainability and equity reach.

## Priority Interview Targets
| Site | Pattern of interest | Hypothesis | Potential interview |
| --- | --- | --- | --- |
| Napa Solano | High reach + Medicaid/substance burden but lowest adherence; lowest pharmacy returns | Pharmacy bandwidth or SUD-specific support limiting maintenance | Site pharmacist lead; care manager supervisor |
| South Sacramento | Highest Medicaid, very low reach, lean case mgmt | Referral/access barriers or staffing constraints; workflow still yields decent adherence once engaged | Clinic manager; referral coordinator; lead care manager |
| South San Francisco | High adherence despite highest SUD burden | Effective SUD-integrated workflows worth spreading | Behavioral health lead; pharmacist; SUD counselor |
| Fresno | Zero Medicaid recorded; high case mgmt, moderate adherence | Data capture issue or payer mix skew; intensive CM may compensate for access gaps | Data/IT lead; billing manager; care manager lead |
| San Rafael | Highest pharmacist returns; moderate reach | Pharmacist model strong—learn staffing ratios and triggers; explore outreach ramp | Pharmacist lead; program manager |
| Central Valley | Very low Medicaid, decent adherence with high CM | Equity in reach may be limited; CM-heavy model sustaining adherence | Outreach lead; care manager supervisor |

## RE-AIM Interpretation
- **Reach:** Structural/referral barriers appear at South Sacramento and Santa Rosa; Fresno and Central Valley may be under-serving Medicaid populations. High monthly reach in San Jose/Napa suggests efficient identification pipelines.
- **Effectiveness:** Adherence resilience is generally strong, but Napa Solano and San Rafael show notable Year 2 decline. Pharmacy engagement correlates with stronger adherence (see `figures/adherence_predictors.png`), especially in sites with higher follow-up counts.
- **Implementation:** Case management intensity varies widely; Fresno/South SF high CM but modest pharmacy could signal CM-driven adherence. Pharmacist engagement peaks at San Rafael; Napa Solano’s low pharmacy follow-ups may explain its adherence dip. Substance use burden tracks with lower adherence in Napa Solano; South SF counters this trend.
- **Maintenance:** Most sites lose 5–13% adherence by Year 2; Santa Rosa is the sole improver. Pharmacist follow-ups drop Year 2 across sites (ratios 0.74–0.90), suggesting post-Year1 staffing or scheduling attrition.

## Recommendations
- Validate data: investigate Fresno Medicaid=0 and ensure payer mix coding is correct.
- Improve maintenance where pharmacy is thin (like Napa Solano and Central Valley) by investigating if reallocating pharmacist time or embedding med refills in CM visits could help.
- Address reach gaps: investigate referral pathways for South Sacramento and Santa Rosa; consider EHR alerts or PCP feedback loops used by San Jose/Napa (highest velocities).
- Equity aspect: assess whether low Medicaid proportions in Central Valley/Fresno reflect access barriers; pair with potential community outreach.
