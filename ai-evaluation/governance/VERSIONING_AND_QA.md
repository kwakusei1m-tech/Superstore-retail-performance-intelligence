# Versioning, calibration and QA

## Version keys

Use `TASK-ID.prompt.v#`, `TASK-ID.rubric.v#`, `source-v#`, `environment-v#` and `run-YYYYMMDD-###`. Any scoring-definition change creates a new rubric version; any changed input or accepted answer creates a new task/source version.

## Calibration cycle

1. Reviewer reads the guideline and independently scores three gold cases.
2. Lead compares criterion-level labels, severity and rationale.
3. Team discusses disagreements without changing scores retrospectively.
4. Guideline is clarified with positive, negative and boundary examples.
5. Reviewer repeats a blind set and must meet the agreed threshold.

Track exact agreement and material-disagreement rate. Use Cohen's kappa for two categorical raters or Krippendorff's alpha when the project has multiple raters/missing judgments; use these only when the team understands their assumptions.

## Production QA

- 100% review of critical-risk cases.
- Risk-based sample of routine cases.
- Blind duplicate items to detect drift.
- Weekly error-pattern review and monthly rubric-version review.
- Adjudication for critical/high disagreement or uncertain source grounding.
- Regression run before a prompt, model, dataset or rubric release.
