# Superstore refresh runbook

## Purpose

Use this runbook to replace the Superstore CSV, refresh the Excel Power Query/Data Model architecture, validate the result and create a controlled reporting release.

## Roles

| Role | Responsibility |
|---|---|
| Refresh operator | Confirms source, updates `pSourcePath` if needed, runs refresh and records results |
| Data owner | Resolves missing columns, invalid values or business exceptions |
| Report reviewer | Reconciles KPIs, tests filters and approves distribution |

For a portfolio project one person may perform all roles, but each control should still be completed.

## Prerequisites

- Desktop Microsoft Excel for Windows with Power Query and Power Pivot enabled.
- A writable working copy of the `.xlsx` workbook.
- A CSV containing the required headers in the data dictionary.
- Stable delimiter and UTF-8-compatible encoding.
- No open Power Query or Power Pivot edit dialog when refresh begins.

## Standard refresh procedure

### 1. Preserve the prior approved version

1. Close the workbook if it is open elsewhere.
2. Save a dated copy of the last approved workbook, for example `archive/Superstore_BI_2026-08-11.xlsx`.
3. Keep the prior CSV until the new refresh is approved.

### 2. Validate and place the source

1. Confirm that the file is a CSV and opens without corruption.
2. Confirm the 21 required headers match the data dictionary exactly.
3. Do not edit source values merely to make a dashboard result look better.
4. Place the file in the controlled local source folder.

### 3. Verify `pSourcePath`

1. In Excel, select **Data > Get Data > Launch Power Query Editor**. If that command is not shown, open **Data > Queries & Connections** and double-click `pSourcePath`.
2. Select `pSourcePath` and verify the complete CSV path.
3. Remove any accidental leading or trailing space.
4. Do not place quotation marks around `pSourcePath` inside `File.Contents(pSourcePath)`.
5. Close the editor without changing other queries.

### 4. Run the refresh

1. Select **Data > Refresh All**, or press `Ctrl+Alt+F5`.
2. Wait until Excel finishes all Power Query and Data Model processing.
3. Do not read or distribute KPI results while a connection still shows **Refreshing**.
4. If Excel appears blocked by a hidden modal window, use `Alt+Tab` once to locate it; do not repeatedly click or terminate Excel during model calculation.

## Mandatory acceptance gates

### Data-quality gate

| Test | Accept | Action when not accepted |
|---|---|---|
| Error-severity checks | All `PASS`; zero failed rows | Stop release; correct source or transformation rule |
| Review-severity checks | Investigated and documented | Explain why retained; escalate unusual changes |
| DQ invalid rows | Zero for baseline; every row understood otherwise | Trace each row in `DQ_InvalidRows` |
| Duplicate line keys | Zero | Investigate duplicated source lines |
| Customer/location key conflicts | Zero rows | Resolve inconsistent dimension attributes before release |

`REVIEW` is not automatically a broken refresh. Negative-profit lines and high-sales outliers are business exceptions that remain visible for analysis. `FAIL` means the workbook should not be distributed.

### Reconciliation gate

1. Confirm `Audit Source Rows = Audit Valid Rows + Audit Rejected Rows`.
2. Confirm `Sales Line Count = Audit Valid Rows`.
3. Confirm `Fact vs Audit Variance = 0`.
4. Compare Total Sales and Total Profit with an independent sum of valid source rows.
5. Confirm Order Count uses distinct Order ID, not the order-line count.
6. Trace at least one Order ID from CSV through FactSales and a PivotTable.

### Date and relationship gate

1. Confirm `Data Coverage Start` and `Data Coverage End` match the refreshed Order Date range.
2. Confirm `Ship-Date Coverage Status = PASS`.
3. Confirm the active relationship is `DimDate[Date] -> FactSales[Order Date]`.
4. Confirm the ship-date relationship exists but is inactive.
5. Test one Order Date measure and one `USERELATIONSHIP` ship-date measure.

### Report gate

1. Clear all slicer and timeline filters and record headline KPI totals.
2. Test Region, Segment, Category and Order Date filters separately.
3. Confirm every business PivotTable listed in Report Connections responds as intended.
4. Inspect charts for missing series, overlapping labels or incorrect number formats.
5. Confirm no report uses an implicit `Sum of Sales`; use `MeasuresHub[Total Sales]`.
6. Confirm negative profit/margin remains red and quality statuses retain PASS/REVIEW/FAIL colors.

## Baseline reconciliation values

These values apply to the current 9,994-line sample and will legitimately change with a new source period.

| KPI | Baseline |
|---|---:|
| Source rows | 9,994 |
| Valid rows | 9,994 |
| Rejected rows | 0 |
| Total Sales | $2,297,200.86 |
| Total Profit | $286,397.02 |
| Profit Margin | 12.47% |
| Distinct orders | 5,009 |
| Customers | 793 |

## Failure recovery

### Source file not found

- Open `pSourcePath` and correct the full path.
- Confirm there is no leading space and that the filename/extension match.
- Verify the file is not on an unavailable network or removable drive.

### Missing-columns error

- Compare the incoming header row with `RequiredColumns` in `stg_Superstore`.
- Restore renamed/missing columns in the upstream export, or document and implement a controlled schema change.
- Never remove a required-field check merely to force refresh success.

### Date or numeric conversion error

- Inspect the failing source values in Power Query.
- Confirm the source uses the expected locale; change `"en-US"` only when the incoming format requires another locale.
- Confirm Discount is stored as a decimal proportion between 0 and 1.

### Relationship cannot refresh

- Run the customer and location conflict queries.
- Verify unique, nonblank lookup keys and matching data types.
- Do not accept many-to-many cardinality as a shortcut.

### Power Pivot or Excel appears frozen

1. Wait for calculation to complete and check the Windows taskbar/`Alt+Tab` for a hidden dialog.
2. Avoid multiple clicks, repeated refresh commands or immediate force-close.
3. If Excel genuinely stops responding for an extended period, terminate only after noting the last completed step, reopen the archived copy and refresh in stages.

## Schema-change policy

| Change | Policy |
|---|---|
| Additional rows or dates | Allowed when existing types/rules hold |
| New customers, products or locations | Allowed; dimension conflict tests must pass |
| New optional column | Controlled change; document whether it belongs in staging, fact, dimension or nowhere |
| Renamed or missing required column | Block refresh until resolved |
| Changed delimiter, encoding or date locale | Controlled source-connector change and full regression test |
| Changed KPI definition | Versioned DAX/documentation change; do not silently overwrite |

## Release sign-off record

Record the following in the release notes or project log:

- refresh UTC timestamp;
- source filename and source date coverage;
- source, valid and rejected row counts;
- DQ status and reviewed exceptions;
- Total Sales, Total Profit, Profit Margin and Order Count;
- reviewer name/role;
- workbook version and Git tag.

## Post-refresh distribution

1. Save the approved workbook with a semantic version, for example `..._v1.0.1.xlsx`.
2. Update the report only when conclusions materially change.
3. Commit source-code/documentation changes to GitHub.
4. Create a GitHub release only after the committed files and attached workbook/report agree.
5. Keep the previous approved release available for rollback.
