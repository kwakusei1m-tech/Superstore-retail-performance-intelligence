# Labeling and reviewer guidelines

## Error taxonomy

- `FACTUAL_GROUNDING`: statement conflicts with an approved source.
- `CALCULATION`: formula, aggregation, unit, denominator or rounding error.
- `INSTRUCTION`: explicit requirement omitted or contradicted.
- `RELEVANCE`: content does not answer the user decision.
- `COMPLETENESS`: necessary section, evidence or action is missing.
- `REASONING`: conclusion does not follow from evidence or overstates causality.
- `LANGUAGE`: grammar, clarity, tone, locale or terminology defect.
- `FORMAT_USABILITY`: file, layout, navigation, accessibility or visual defect.
- `TOOL_WORKFLOW`: incorrect tool choice, failed action or wrong final state.
- `SAFETY_PRIVACY`: confidential, personal or unsafe information mishandled.
- `TASK_AMBIGUITY`: task or source pack does not support a single fair judgment.
- `GRADER_DEFECT`: scoring rule is invalid, inconsistent or gameable.
- `ENVIRONMENT`: tool or infrastructure failure independent of model behavior.

## Severity

- **Critical:** unsafe/destructive action, sensitive-data exposure, fabricated source, wrong deliverable or decision-invalidating error.
- **High:** material KPI, instruction, reasoning or workflow error requiring major revision.
- **Medium:** meaningful omission or clarity/usability problem with limited decision impact.
- **Low:** localized style, grammar or presentation defect that does not change meaning.

## Reviewer rules

1. Score only observable criteria.
2. Separate facts from preferences.
3. Use an `Unknown/Insufficient evidence` outcome when evidence cannot support a fair score.
4. Do not infer multilingual competence; language tasks require a verified fluent reviewer and locale-specific gold guidance.
5. Do not reward a persuasive answer that contradicts source data.
6. Do not penalize a valid alternative path unless the task requires a specific process.
7. Record uncertainty and escalate critical/high disagreements.
