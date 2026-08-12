let
    S = stg_Superstore,
    DuplicateGroups =
        Table.SelectRows(
            Table.Group(
                S,
                {"LineKey"},
                {{"Rows", each Table.RowCount(_), Int64.Type}}
            ),
            each [Rows] > 1
        ),
    DuplicateRows =
        if Table.IsEmpty(DuplicateGroups) then 0
        else List.Sum(DuplicateGroups[Rows]),
    Checks =
        #table(
            type table
            [
                Check = text,
                FailRows = Int64.Type,
                Severity = text,
                Expected = text
            ],
            {
                {
                    "Invalid rows",
                    Table.RowCount(Table.SelectRows(S, each [DQ Status] = "FAIL")),
                    "Error",
                    "0"
                },
                {
                    "Blank/error Row ID",
                    Table.RowCount(Table.SelectRows(S, each [Row ID Check] <> "OK")),
                    "Error",
                    "0"
                },
                {
                    "Blank Order ID",
                    Table.RowCount(Table.SelectRows(S, each [Order Check] <> "OK")),
                    "Error",
                    "0"
                },
                {
                    "Blank Product ID",
                    Table.RowCount(Table.SelectRows(S, each [Product Check] <> "OK")),
                    "Error",
                    "0"
                },
                {
                    "Blank customer identifier/name",
                    Table.RowCount(Table.SelectRows(S, each [Customer Check] <> "OK")),
                    "Error",
                    "0"
                },
                {
                    "Sales blank/error/negative",
                    Table.RowCount(Table.SelectRows(S, each [Sales Check] <> "OK")),
                    "Error",
                    "0"
                },
                {
                    "Profit blank/error",
                    Table.RowCount(Table.SelectRows(S, each [Profit Check] <> "OK")),
                    "Error",
                    "0"
                },
                {
                    "Quantity blank/error/invalid",
                    Table.RowCount(Table.SelectRows(S, each [Quantity Check] <> "OK")),
                    "Error",
                    "0"
                },
                {
                    "Discount blank/error/out of range",
                    Table.RowCount(Table.SelectRows(S, each [Discount Check] <> "OK")),
                    "Error",
                    "0"
                },
                {
                    "Invalid order/ship date",
                    Table.RowCount(Table.SelectRows(S, each [Date Check] <> "OK")),
                    "Error",
                    "0"
                },
                {
                    "Duplicate LineKey rows",
                    DuplicateRows,
                    "Error",
                    "0"
                },
                {
                    "Negative-profit rows",
                    Table.RowCount(Table.SelectRows(S, each [Profit Status] = "Loss")),
                    "Review",
                    "Business review"
                },
                {
                    "High-sales outliers",
                    Table.RowCount(Table.SelectRows(S, each [Sales Outlier] = "Review")),
                    "Review",
                    "Validate, do not auto-delete"
                }
            }
        ),
    AddStatus =
        Table.AddColumn(
            Checks,
            "Status",
            each
                if [FailRows] = 0 then "PASS"
                else if [Severity] = "Review" then "REVIEW"
                else "FAIL",
            type text
        )
in
    AddStatus
