# DAX measure catalogue

This catalogue documents the 63 explicit measures identified in the completed Excel Data Model. The recommended home table for every measure is `MeasuresHub`; the table itself does not need a relationship.

> In the Power Pivot calculation area, enter measures as `Measure Name:=formula`. In **Measures > Manage Measures**, set **Table name / Home Table** to `MeasuresHub`. If your regional settings use semicolons, replace argument-separating commas with semicolons.

## 1. Core performance measures

```DAX
Total Sales :=
SUM ( FactSales[Sales] )

Total Profit :=
SUM ( FactSales[Profit] )

Total Quantity :=
SUM ( FactSales[Quantity] )

Sales Line Count :=
COUNTROWS ( FactSales )

Order Count :=
DISTINCTCOUNT ( FactSales[Order ID] )

Customer Count :=
DISTINCTCOUNT ( FactSales[Customer ID] )

Product Count :=
DISTINCTCOUNT ( FactSales[Product ID] )

Average Order Value :=
DIVIDE ( [Total Sales], [Order Count], 0 )

Average Profit per Order :=
DIVIDE ( [Total Profit], [Order Count], 0 )

Average Selling Price :=
DIVIDE ( [Total Sales], [Total Quantity], 0 )

Profit Margin % :=
DIVIDE ( [Total Profit], [Total Sales], 0 )

Average Discount % :=
AVERAGE ( FactSales[Discount] )

Average Ship Days :=
AVERAGE ( FactSales[Ship Days] )
```

## 2. Profitability and discount diagnostics

```DAX
Discounted Sales :=
CALCULATE (
    [Total Sales],
    KEEPFILTERS ( FactSales[Discount] > 0 )
)

Discounted Profit :=
CALCULATE (
    [Total Profit],
    KEEPFILTERS ( FactSales[Discount] > 0 )
)

Discounted Profit Margin % :=
DIVIDE ( [Discounted Profit], [Discounted Sales], 0 )

Discounted Sales % :=
DIVIDE ( [Discounted Sales], [Total Sales], 0 )

Negative Profit :=
CALCULATE (
    [Total Profit],
    KEEPFILTERS ( FactSales[Profit] < 0 )
)

Loss-Making Line Count :=
CALCULATE (
    [Sales Line Count],
    KEEPFILTERS ( FactSales[Profit] < 0 )
)

Loss-Making Line % :=
DIVIDE ( [Loss-Making Line Count], [Sales Line Count], 0 )

High-Discount Sales :=
CALCULATE (
    [Total Sales],
    KEEPFILTERS ( FactSales[Discount] > 0.20 )
)

High-Discount Profit :=
CALCULATE (
    [Total Profit],
    KEEPFILTERS ( FactSales[Discount] > 0.20 )
)

High-Discount Profit Margin % :=
DIVIDE ( [High-Discount Profit], [High-Discount Sales], 0 )

Loss Amount :=
- [Negative Profit]
```

## 3. Time intelligence

These measures require `DimDate` to be marked as the Date Table, the active `DimDate[Date]` to `FactSales[Order Date]` relationship, and the inactive ship-date relationship shown in the model documentation.

```DAX
Sales Previous Year :=
CALCULATE (
    [Total Sales],
    SAMEPERIODLASTYEAR ( DimDate[Date] )
)

Profit Previous Year :=
CALCULATE (
    [Total Profit],
    SAMEPERIODLASTYEAR ( DimDate[Date] )
)

Sales YoY Change :=
[Total Sales] - [Sales Previous Year]

Sales YoY % :=
DIVIDE ( [Sales YoY Change], [Sales Previous Year] )

Profit YoY Change :=
[Total Profit] - [Profit Previous Year]

Profit YoY % :=
DIVIDE ( [Profit YoY Change], [Profit Previous Year] )

Sales YTD :=
TOTALYTD ( [Total Sales], DimDate[Date] )

Profit YTD :=
TOTALYTD ( [Total Profit], DimDate[Date] )

Sales Previous Month :=
CALCULATE (
    [Total Sales],
    DATEADD ( DimDate[Date], -1, MONTH )
)

Sales MoM Change :=
[Total Sales] - [Sales Previous Month]

Sales by Ship Date :=
CALCULATE (
    [Total Sales],
    USERELATIONSHIP ( DimDate[Date], FactSales[Ship Date] )
)

Profit by Ship Date :=
CALCULATE (
    [Total Profit],
    USERELATIONSHIP ( DimDate[Date], FactSales[Ship Date] )
)

Orders by Ship Date :=
CALCULATE (
    [Order Count],
    USERELATIONSHIP ( DimDate[Date], FactSales[Ship Date] )
)
```

## 4. Ranking and contribution

```DAX
Category Sales Rank :=
IF (
    HASONEVALUE ( DimProduct[Category] ),
    RANKX (
        ALL ( DimProduct[Category] ),
        [Total Sales],
        ,
        DESC,
        DENSE
    )
)

Region Profit Rank :=
IF (
    HASONEVALUE ( DimLocation[Region] ),
    RANKX (
        ALL ( DimLocation[Region] ),
        [Total Profit],
        ,
        DESC,
        DENSE
    )
)

Customer Sales Rank :=
IF (
    HASONEVALUE ( DimCustomer[Customer Name] ),
    RANKX (
        ALL ( DimCustomer[Customer Name] ),
        [Total Sales],
        ,
        DESC,
        DENSE
    )
)

Product Sales Rank :=
IF (
    HASONEVALUE ( DimProduct[Product Name] ),
    RANKX (
        ALL ( DimProduct[Product Name] ),
        [Total Sales],
        ,
        DESC,
        DENSE
    )
)

Category Sales Contribution % :=
DIVIDE (
    [Total Sales],
    CALCULATE ( [Total Sales], ALL ( DimProduct[Category] ) ),
    0
)

Region Sales Contribution % :=
DIVIDE (
    [Total Sales],
    CALCULATE ( [Total Sales], ALL ( DimLocation[Region] ) ),
    0
)

Customer Sales Contribution % :=
DIVIDE (
    [Total Sales],
    CALCULATE ( [Total Sales], ALL ( DimCustomer[Customer Name] ) ),
    0
)

Product Sales Contribution % :=
DIVIDE (
    [Total Sales],
    CALCULATE ( [Total Sales], ALL ( DimProduct[Product Name] ) ),
    0
)

Top 10 Customer Sales :=
CALCULATE (
    [Total Sales],
    TOPN (
        10,
        ALL ( DimCustomer[Customer Name] ),
        [Total Sales],
        DESC
    )
)

Top 10 Customer Contribution % :=
DIVIDE ( [Top 10 Customer Sales], [Total Sales], 0 )
```

## 5. Data quality and refresh measures

`DQ Failed Check Count` counts checks with a non-zero flag count. Because the quality table contains both Error and Review severities, `DQ Overall Status` distinguishes a release-blocking `FAIL` from a business-review `REVIEW`.

```DAX
DQ Check Count :=
COUNTROWS ( Data_Checks )

DQ Failed Check Count :=
CALCULATE (
    COUNTROWS ( Data_Checks ),
    FILTER ( Data_Checks, Data_Checks[FailRows] > 0 )
)

DQ Failure Instances :=
SUM ( Data_Checks[FailRows] )

DQ Pass Rate % :=
DIVIDE (
    [DQ Check Count] - [DQ Failed Check Count],
    [DQ Check Count],
    0
)

DQ Overall Status :=
SWITCH (
    TRUE (),
    CALCULATE ( COUNTROWS ( Data_Checks ), Data_Checks[Status] = "FAIL" ) > 0, "FAIL",
    CALCULATE ( COUNTROWS ( Data_Checks ), Data_Checks[Status] = "REVIEW" ) > 0, "REVIEW",
    "PASS"
)

Audit Source Rows :=
MAX ( Refresh_Audit[RowCount] )

Audit Valid Rows :=
MAX ( Refresh_Audit[ValidRowCount] )

Audit Rejected Rows :=
[Audit Source Rows] - [Audit Valid Rows]

Fact vs Audit Variance :=
[Sales Line Count] - [Audit Valid Rows]

Last Refresh UTC :=
MAX ( Refresh_Audit[RefreshUTC] )

Data Coverage Start :=
MIN ( Refresh_Audit[MinOrderDate] )

Data Coverage End :=
MAX ( Refresh_Audit[MaxOrderDate] )

Model Health Status :=
SWITCH (
    TRUE (),
    [Fact vs Audit Variance] <> 0, "FAIL",
    [DQ Overall Status] = "FAIL", "FAIL",
    [DQ Overall Status] = "REVIEW", "REVIEW",
    "PASS"
)

Max Ship Date :=
MAX ( FactSales[Ship Date] )

Calendar End :=
CALCULATE ( MAX ( DimDate[Date] ), ALL ( DimDate ) )

Ship-Date Coverage Status :=
IF ( [Max Ship Date] <= [Calendar End], "PASS", "EXTEND DimDate" )
```

## Formatting catalogue

| Format | Measures |
|---|---|
| Currency, 2 decimals | Total Sales; Total Profit; Average Order Value; Average Profit per Order; Average Selling Price; Discounted Sales; Discounted Profit; Negative Profit; High-Discount Sales; High-Discount Profit; Loss Amount; Sales/Profit previous period, change, YTD and ship-date amounts; Top 10 Customer Sales |
| Percentage, 1–2 decimals | Profit Margin %; Average Discount %; Discounted Profit Margin %; Discounted Sales %; Loss-Making Line %; High-Discount Profit Margin %; Sales YoY %; Profit YoY %; contribution measures; DQ Pass Rate % |
| Whole number | Total Quantity; Sales Line Count; Order Count; Customer Count; Product Count; Loss-Making Line Count; Orders by Ship Date; rank measures; DQ and audit row-count measures; Fact vs Audit Variance |
| Decimal, 1 decimal | Average Ship Days |
| Date | Data Coverage Start; Data Coverage End; Max Ship Date; Calendar End |
| Date/time | Last Refresh UTC |
| Text | DQ Overall Status; Model Health Status; Ship-Date Coverage Status |

## Validation checklist

1. `Total Sales` = **$2,297,200.86** and `Total Profit` = **$286,397.02** with no filters.
2. `Sales Line Count` = `Audit Valid Rows` = **9,994** and `Fact vs Audit Variance` = **0**.
3. `Order Count` = **5,009**; it must not equal the order-line count.
4. `Profit Margin %` = `Total Profit / Total Sales` = approximately **12.47%**.
5. Prior-year and YTD measures respond to the Order Date timeline.
6. Ship-date measures return values only through `USERELATIONSHIP`.
7. `Ship-Date Coverage Status` returns `PASS` after every refresh.
8. All measures appear under `MeasuresHub` in PivotTable Fields; `_Measures` contains no explicit measures and is hidden from Client Tools.
