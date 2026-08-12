let
    Source =
        Csv.Document(
            File.Contents(pSourcePath),
            [
                Delimiter = ",",
                Encoding = 65001,
                QuoteStyle = QuoteStyle.Csv
            ]
        ),

    PromotedHeaders =
        Table.PromoteHeaders(
            Source,
            [PromoteAllScalars = true]
        ),

    CleanColumnNames =
        Table.TransformColumnNames(
            PromotedHeaders,
            each Text.Trim(Text.Clean(_))
        ),

    RequiredColumns = {
        "Row ID", "Order ID", "Order Date", "Ship Date", "Ship Mode",
        "Customer ID", "Customer Name", "Segment", "Country", "City",
        "State", "Postal Code", "Region", "Product ID", "Category",
        "Sub-Category", "Product Name", "Sales", "Quantity",
        "Discount", "Profit"
    },

    MissingColumns =
        List.Difference(
            RequiredColumns,
            Table.ColumnNames(CleanColumnNames)
        ),

    SchemaValidated =
        if List.IsEmpty(MissingColumns) then
            CleanColumnNames
        else
            error
                "Required columns are missing: "
                & Text.Combine(MissingColumns, ", "),

    TextColumns = {
        "Order ID", "Ship Mode", "Customer ID", "Customer Name",
        "Segment", "Country", "City", "State", "Postal Code",
        "Region", "Product ID", "Category", "Sub-Category",
        "Product Name"
    },

    CleanText =
        Table.TransformColumns(
            SchemaValidated,
            List.Transform(
                TextColumns,
                (ColumnName) => {
                    ColumnName,
                    each
                        if _ = null then null
                        else Text.Trim(Text.Clean(Text.From(_))),
                    type text
                }
            )
        ),

    Typed =
        Table.TransformColumnTypes(
            CleanText,
            {
                {"Row ID", Int64.Type},
                {"Order Date", type date},
                {"Ship Date", type date},
                {"Sales", Currency.Type},
                {"Quantity", Int64.Type},
                {"Discount", type number},
                {"Profit", Currency.Type}
            },
            "en-US"
        ),

    AddRowCheck =
        Table.AddColumn(
            Typed,
            "Row ID Check",
            each
                try
                    if [Row ID] = null then "Blank"
                    else "OK"
                otherwise "Error",
            type text
        ),

    AddOrderCheck =
        Table.AddColumn(
            AddRowCheck,
            "Order Check",
            each
                if [Order ID] = null or [Order ID] = ""
                then "Blank"
                else "OK",
            type text
        ),

    AddProductCheck =
        Table.AddColumn(
            AddOrderCheck,
            "Product Check",
            each
                if [Product ID] = null or [Product ID] = ""
                then "Blank"
                else "OK",
            type text
        ),

    AddCustomerCheck =
        Table.AddColumn(
            AddProductCheck,
            "Customer Check",
            each
                if [Customer ID] = null or [Customer ID] = ""
                    or [Customer Name] = null or [Customer Name] = ""
                then "Blank"
                else "OK",
            type text
        ),

    AddSalesCheck =
        Table.AddColumn(
            AddCustomerCheck,
            "Sales Check",
            each
                try
                    if [Sales] = null then "Blank"
                    else if [Sales] < 0 then "Negative"
                    else "OK"
                otherwise "Error",
            type text
        ),

    AddProfitCheck =
        Table.AddColumn(
            AddSalesCheck,
            "Profit Check",
            each
                try
                    if [Profit] = null then "Blank"
                    else "OK"
                otherwise "Error",
            type text
        ),

    AddQuantityCheck =
        Table.AddColumn(
            AddProfitCheck,
            "Quantity Check",
            each
                try
                    if [Quantity] = null then "Blank"
                    else if [Quantity] <= 0 then "Invalid"
                    else "OK"
                otherwise "Error",
            type text
        ),

    AddDiscountCheck =
        Table.AddColumn(
            AddQuantityCheck,
            "Discount Check",
            each
                try
                    if [Discount] = null then "Blank"
                    else if [Discount] < 0 or [Discount] > 1
                        then "Out of Range"
                    else "OK"
                otherwise "Error",
            type text
        ),

    AddDateCheck =
        Table.AddColumn(
            AddDiscountCheck,
            "Date Check",
            each
                try
                    if [Order Date] = null or [Ship Date] = null
                        then "Blank"
                    else if [Ship Date] < [Order Date]
                        then "Ship before order"
                    else "OK"
                otherwise "Error",
            type text
        ),

    ReplaceConversionErrors =
        Table.ReplaceErrorValues(
            AddDateCheck,
            {
                {"Row ID", null},
                {"Order Date", null},
                {"Ship Date", null},
                {"Sales", null},
                {"Quantity", null},
                {"Discount", null},
                {"Profit", null}
            }
        ),

    AddLineKey =
        Table.AddColumn(
            ReplaceConversionErrors,
            "LineKey",
            each
                Text.Combine(
                    List.Transform(
                        {[Order ID], [Product ID], [Row ID]},
                        (Value) =>
                            if Value = null then ""
                            else Text.From(Value)
                    ),
                    "|"
                ),
            type text
        ),

    AddLocationKey =
        Table.AddColumn(
            AddLineKey,
            "LocationKey",
            each
                Text.Combine(
                    List.Transform(
                        {
                            [Country], [Region], [State],
                            [City], [Postal Code]
                        },
                        (Value) =>
                            if Value = null then ""
                            else Text.From(Value)
                    ),
                    "|"
                ),
            type text
        ),

    AddShipDays =
        Table.AddColumn(
            AddLocationKey,
            "Ship Days",
            each
                try Duration.Days([Ship Date] - [Order Date])
                otherwise null,
            Int64.Type
        ),

    AddProfitStatus =
        Table.AddColumn(
            AddShipDays,
            "Profit Status",
            each
                if [Profit] = null then "Missing"
                else if [Profit] < 0 then "Loss"
                else if [Profit] = 0 then "Break-even"
                else "Profit",
            type text
        ),

    AddDiscountBand =
        Table.AddColumn(
            AddProfitStatus,
            "Discount Band",
            each
                if [Discount] = null then "Missing"
                else if [Discount] = 0 then "No Discount"
                else if [Discount] <= 0.10 then "Low: 1%-10%"
                else if [Discount] <= 0.20 then "Medium: 11%-20%"
                else if [Discount] <= 0.40 then "High: 21%-40%"
                else "Very High: >40%",
            type text
        ),

    SalesValues = List.RemoveNulls(AddDiscountBand[Sales]),

    SalesMean =
        if List.Count(SalesValues) = 0 then null
        else List.Average(SalesValues),

    SalesStdDev =
        if List.Count(SalesValues) <= 1 then null
        else List.StandardDeviation(SalesValues),

    AddSalesOutlier =
        Table.AddColumn(
            AddDiscountBand,
            "Sales Outlier",
            each
                if [Sales] = null or SalesStdDev = null
                    then "Not Tested"
                else if [Sales] > SalesMean + (3 * SalesStdDev)
                    then "Review"
                else "OK",
            type text
        ),

    AddDQStatus =
        Table.AddColumn(
            AddSalesOutlier,
            "DQ Status",
            each
                if [Row ID Check] = "OK"
                    and [Order Check] = "OK"
                    and [Product Check] = "OK"
                    and [Customer Check] = "OK"
                    and [Sales Check] = "OK"
                    and [Profit Check] = "OK"
                    and [Quantity Check] = "OK"
                    and [Discount Check] = "OK"
                    and [Date Check] = "OK"
                then "PASS"
                else "FAIL",
            type text
        ),

    Final =
        Table.ReorderColumns(
            AddDQStatus,
            List.Combine(
                {
                    RequiredColumns,
                    {
                        "LineKey", "LocationKey", "Ship Days",
                        "Profit Status", "Discount Band",
                        "Sales Outlier", "DQ Status",
                        "Row ID Check", "Order Check",
                        "Product Check", "Customer Check",
                        "Sales Check", "Profit Check",
                        "Quantity Check", "Discount Check",
                        "Date Check"
                    }
                }
            )
        )
in
    Final
