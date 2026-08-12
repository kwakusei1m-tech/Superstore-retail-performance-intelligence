let
    Source = int_ValidSales,
    KeepColumns =
        Table.SelectColumns(
            Source,
            {"Customer ID", "Customer Name", "Segment"}
        ),
    NonBlankKeys =
        Table.SelectRows(
            KeepColumns,
            each [Customer ID] <> null and [Customer ID] <> ""
        ),
    DimCustomer =
        Table.Distinct(
            NonBlankKeys,
            {"Customer ID"}
        )
in
    DimCustomer
