# Superstore data dictionary

## Model scope

| Property | Definition |
|---|---|
| Analytical grain | One row in `FactSales` represents one order-product line |
| Business date | `Order Date` for standard reporting |
| Alternative date | `Ship Date`, activated only by dedicated DAX measures |
| Reporting currency | US dollars |
| Baseline row count | 9,994 valid sales lines |
| Baseline coverage | 3 January 2014 to 30 December 2017 for order dates; `DimDate` extends through the end of the latest order/ship year |

## Source fields

| Column | Type | Meaning | Validation rule |
|---|---|---|---|
| Row ID | Whole number | Source row identifier | Required; expected unique |
| Order ID | Text | Business order identifier | Required; may repeat across order lines |
| Order Date | Date | Date the order was placed | Required; must be on or before Ship Date |
| Ship Date | Date | Date the order line shipped | Required; must be on or after Order Date |
| Ship Mode | Text | Shipping-service category | Trimmed and cleaned |
| Customer ID | Text | Customer business key | Required |
| Customer Name | Text | Customer display name | Required for a valid customer |
| Segment | Text | Customer segment | Trimmed and cleaned |
| Country | Text | Country name | Component of `LocationKey` |
| City | Text | City name | Component of `LocationKey` |
| State | Text | State name | Component of `LocationKey` |
| Postal Code | Text | Postal code | Stored as text; component of `LocationKey` |
| Region | Text | Reporting region | Descriptive attribute, not a unique key |
| Product ID | Text | Product business key | Required |
| Category | Text | High-level product classification | Trimmed and cleaned |
| Sub-Category | Text | Detailed product classification | Trimmed and cleaned |
| Product Name | Text | Product display name | Trimmed and cleaned |
| Sales | Currency | Gross sales value for the order line | Required; non-negative |
| Quantity | Whole number | Units sold on the order line | Required; greater than zero |
| Discount | Decimal | Discount proportion | Required; range 0 to 1 |
| Profit | Currency | Supplied profit value for the order line | Required; negative values allowed for analysis |

## Power Query derived and control fields

| Column | Type | Definition |
|---|---|---|
| LineKey | Text | `Order ID | Product ID | Row ID`; single-column line-level uniqueness key |
| LocationKey | Text | `Country | Region | State | City | Postal Code`; single relationship key for location |
| Ship Days | Whole number | Calendar days between Order Date and Ship Date |
| Profit Status | Text | `Profit`, `Break-even`, `Loss` or `Missing` |
| Discount Band | Text | No Discount; Low 1–10%; Medium 11–20%; High 21–40%; Very High over 40%; Missing |
| Sales Outlier | Text | `Review` when Sales exceeds mean plus three standard deviations; otherwise `OK`/`Not Tested` |
| DQ Status | Text | `PASS` only when every release-blocking row rule passes; otherwise `FAIL` |
| Row ID Check | Text | Row ID completeness/conversion result |
| Order Check | Text | Order ID completeness result |
| Product Check | Text | Product ID completeness result |
| Customer Check | Text | Customer ID/name completeness result |
| Sales Check | Text | Sales completeness, conversion and non-negative result |
| Profit Check | Text | Profit completeness and conversion result |
| Quantity Check | Text | Quantity completeness, conversion and positive-value result |
| Discount Check | Text | Discount completeness, conversion and range result |
| Date Check | Text | Date completeness, conversion and chronological result |

## Data Model tables

### FactSales

| Column | Role | Description |
|---|---|---|
| Row ID | Technical identifier | Original source row identifier |
| LineKey | Degenerate key | Unique order-line validation key |
| Order ID | Degenerate dimension | Order identifier used by distinct-order measures |
| Order Date | Foreign date key | Active relationship to `DimDate[Date]` |
| Ship Date | Foreign date key | Inactive relationship to `DimDate[Date]` |
| Ship Mode | Attribute | Shipping mode for analysis |
| Customer ID | Foreign key | Many-side key to `DimCustomer` |
| Product ID | Foreign key | Many-side key to `DimProduct` |
| LocationKey | Foreign key | Many-side key to `DimLocation` |
| Sales | Additive fact | Sales amount |
| Quantity | Additive fact | Units sold |
| Discount | Non-additive fact | Line-level discount proportion |
| Profit | Additive fact | Profit amount |
| Ship Days | Semi-additive diagnostic | Delivery-cycle duration |
| Profit Status | Diagnostic attribute | Profit/loss classification |
| Discount Band | Diagnostic attribute | Ordered discount classification |
| Sales Outlier | Diagnostic attribute | Statistical review flag |

### DimProduct

| Column | Role | Description |
|---|---|---|
| Product ID | Primary key | Unique product business key |
| Product Name | Attribute | Product display name |
| Category | Attribute | Product category |
| Sub-Category | Attribute | Product sub-category |

### DimCustomer

| Column | Role | Description |
|---|---|---|
| Customer ID | Primary key | Unique customer business key |
| Customer Name | Attribute | Customer display name |
| Segment | Attribute | Consumer, Corporate or Home Office grouping |

### DimLocation

| Column | Role | Description |
|---|---|---|
| LocationKey | Primary key | Materialized composite geographic key |
| Country | Attribute | Country |
| Region | Attribute | Reporting region |
| State | Attribute | State |
| City | Attribute | City |
| Postal Code | Attribute | Postal code stored as text |

### DimDate

| Column | Type | Sort/usage |
|---|---|---|
| Date | Date | Unique primary key; mark the table by this column |
| Year | Whole number | Calendar year |
| Quarter | Text | Sort by Quarter No |
| Quarter No | Whole number | 1–4 |
| Month | Text | Abbreviated month; sort by Month No |
| Month Name | Text | Full month; sort by Month No |
| Month No | Whole number | 1–12 |
| Year Month | Text | `yyyy-MM`; sort by Year Month Sort |
| Year Month Sort | Whole number | `Year * 100 + Month No` |
| Weekday | Text | Abbreviated weekday; sort by Weekday No |
| Weekday No | Whole number | Monday = 1 through Sunday = 7 |

### Data_Checks

| Column | Description |
|---|---|
| Check | Quality-rule name |
| FailRows | Count of records or instances flagged by the rule |
| Severity | `Error` for release-blocking rules; `Review` for analytical exceptions |
| Expected | Acceptance expectation or review instruction |
| Status | `PASS`, `REVIEW` or `FAIL` derived from count and severity |

### Refresh_Audit

| Column | Description |
|---|---|
| RefreshUTC | UTC timestamp fixed during the current query evaluation |
| SourcePath | Parameter value used for the refresh |
| RowCount | Source rows read by staging |
| ValidRowCount | Rows that passed the row-level quality gate |
| MinOrderDate | Earliest valid Order Date |
| MaxOrderDate | Latest valid Order Date |

### Support objects

| Object | Layer | Purpose |
|---|---|---|
| `pSourcePath` | Power Query parameter | Separates source location from transformation logic |
| `stg_Superstore` | Power Query staging | Complete governed source transformation |
| `int_ValidSales` | Power Query intermediate | PASS-only source for analytical model tables |
| `DQ_InvalidRows` | Power Query exception output | Visible rejected-row register when loaded to a worksheet |
| `DQ_CustomerKeyConflicts` | Power Query control | Confirms one attribute combination per Customer ID |
| `DQ_LocationKeyConflicts` | Power Query control | Confirms one attribute combination per LocationKey |
| `_Measures` | Power Query technical table | Legacy one-row table retained for compatibility; no business measures should remain here |
| `MeasuresHub` | Power Pivot table | Presentation home for explicit DAX measures; deliberately absent from Queries & Connections |

## Relationships

| Lookup side | Fact side | Cardinality | State |
|---|---|---|---|
| `DimDate[Date]` | `FactSales[Order Date]` | One-to-many | Active |
| `DimDate[Date]` | `FactSales[Ship Date]` | One-to-many | Inactive; invoked with `USERELATIONSHIP` |
| `DimProduct[Product ID]` | `FactSales[Product ID]` | One-to-many | Active |
| `DimCustomer[Customer ID]` | `FactSales[Customer ID]` | One-to-many | Active |
| `DimLocation[LocationKey]` | `FactSales[LocationKey]` | One-to-many | Active |
