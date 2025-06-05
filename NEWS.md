# boinet 1.2.0

* Updated descriptions of stopping.prob.T and stopping.prob.E in boinet(), gboinet(),
tite.boinet(), and tite.gboinet().

* Changed a phrase of Stop % to No OBD % in output from boinet(), gboinet(),
tite.boinet(), and tite.gboinet().

* Fixed a bug in gridoptim(), regarding the matrix processing.

* Fixed a bug in boinet(), gboinet(), tite.boinet(), and tite.gboinet(),
regarding the dose-escalation procedure when the next cohort dose level is
chosen based on the maximum efficacy probability.

* Added result formatting system:
  - `format_boinet_results()`: Main function to format simulation results into
    multiple output formats ("list", "tidy", "gt_ready")

* Added gt table integration:
  - `create_boinet_tables()`: Quick creation of publication-ready gt tables
  - `create_oc_gt_table()`: Create formatted operating characteristics tables
  - `create_design_gt_table()`: Create formatted design parameter tables

* Enhanced data extraction:
  - `extract_boinet_data()`: Convenience function to extract tidy data frames for analysis
  - `extract_operating_characteristics()`: Extract OC data in tidy format
  - `extract_design_summary()`: Extract design parameters in tabular format

* Improved summary methods:
  - `summary.boinet()`: Enhanced summary for BOIN-ET results
  - `summary.tite.boinet()`: Enhanced summary for TITE-BOIN-ET results
  - `summary.gboinet()`: Enhanced summary for gBOIN-ET results
  - `summary.tite.gboinet()`: Enhanced summary for TITE-gBOIN-ET results

# boinet 1.1.0

* Fixed a bug in boinet(), gboinet(), tite.boinet(), and tite.gboinet(),
regarding the count for Stop % when the number of patients at the current dose
reaches the early study termination criteria.
 
# boinet 1.0.0

* Added a `NEWS.md` file to track changes to the package.
