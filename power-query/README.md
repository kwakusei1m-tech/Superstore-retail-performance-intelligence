# Power Query M catalogue

This folder contains the final repository-safe M definitions extracted from the Excel workbook and cleaned for reuse.

## Query inventory and load settings

| Query | Purpose | Recommended load |
|---|---|---|
| `pSourcePath` | Text parameter containing the local CSV path | Connection only |
| `stg_Superstore` | Import, typing, cleansing, keys and row-level DQ flags | Connection only |
| `int_ValidSales` | PASS-only governed intermediate | Connection only |
| `Data_Checks` | Aggregated PASS/REVIEW/FAIL control table | Data Model |
| `DQ_InvalidRows` | Rejected-record register | Optional worksheet table |
| `Refresh_Audit` | Current refresh timestamp, source path, row counts and coverage | Data Model + optional audit table |
| `FactSales` | Order-line fact table | Data Model |
| `DimProduct` | Product lookup | Data Model |
| `DimCustomer` | Customer lookup | Data Model |
| `DQ_CustomerKeyConflicts` | Customer-key attribute conflict test | Connection only |
| `DimLocation` | Geographic lookup | Data Model |
| `DQ_LocationKeyConflicts` | Location-key attribute conflict test | Connection only |
| `DimDate` | Calendar covering both order and ship dates | Data Model |
| `_Measures` | One-row technical table retained for workbook compatibility | Data Model; hide from Client Tools |

## How to export or restore a query manually

1. In Excel, select **Data > Queries & Connections**.
2. Double-click the query to open Power Query Editor.
3. Select **Home > Advanced Editor**.
4. Copy only the expression beginning with `let` and ending with the expression after `in`.
5. Paste it into a UTF-8 text file named exactly like the query, with the `.m` extension.
6. For `pSourcePath`, publish only a generic example path. Never commit a personal path, username, credential or network share.

The files are documentation and source control; Excel does not automatically read `.m` files during refresh. To rebuild a query, create a Blank Query, rename it, open Advanced Editor and paste the corresponding definition.

## Repository cleanup applied

- The personal `pSourcePath` value and its accidental leading space were removed.
- No-op inspection steps such as `Table.SelectRows(..., each true)` were removed.
- `DimDate` retains one authoritative sort key per label and includes both order-date and ship-date boundaries.
