# Data source

The project expects a CSV with the 21 source columns documented in [`../docs/data-dictionary.md`](../docs/data-dictionary.md).

For a local refresh:

1. Save the source as `Sample - Superstore_raw_data.csv` or retain the filename used by your local parameter.
2. Open the Excel workbook and update the Power Query parameter `pSourcePath` to the full local file path.
3. Use **Data > Refresh All**.
4. Accept the refresh only after the data-quality and reconciliation checks in the refresh runbook pass.

The repository may omit the full raw dataset when redistribution rights are uncertain. The workbook, query source, schema and validated aggregate results remain documented so the analytical method is reproducible with an appropriately licensed copy of the same-schema dataset.
