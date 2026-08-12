let
    Source = int_ValidSales,
    KeepColumns =
        Table.SelectColumns(
            Source,
            {"Product ID", "Product Name", "Category", "Sub-Category"}
        ),
    NonBlankKeys =
        Table.SelectRows(
            KeepColumns,
            each [Product ID] <> null and [Product ID] <> ""
        ),
    DimProduct =
        Table.Distinct(
            NonBlankKeys,
            {"Product ID"}
        )
in
    DimProduct
