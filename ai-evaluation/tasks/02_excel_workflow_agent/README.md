# Task 02 - Excel workflow agent evaluation

## Prompt
Starting from a supplied CSV and workbook shell, create a refreshable Excel analysis that imports and standardizes data, separates valid and rejected records, loads a governed model, calculates the approved KPIs and produces an executive dashboard. Preserve the original files and document refresh instructions.

## Outcome checks
- Required workbook exists, opens and uses the requested filename.
- `pSourcePath` and `stg_Superstore` are present and refreshable.
- valid/rejected logic, duplicate/key checks and Refresh_Audit are visible.
- model relationships use the documented grain; measures reconcile to gold anchors.
- dashboard filters work; the report explains assumptions and next actions.

## Grading
Use deterministic file/name/table/KPI checks where possible. Grade outcome over exact clicks. Review the trace for prohibited actions, repeated failures, unapproved file overwrites and inefficient recovery.
