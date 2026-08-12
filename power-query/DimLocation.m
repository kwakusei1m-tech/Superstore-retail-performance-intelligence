let
    Source = int_ValidSales,
    KeepColumns =
        Table.SelectColumns(
            Source,
            {
                "LocationKey", "Country", "Region",
                "State", "City", "Postal Code"
            }
        ),
    NonBlankKeys =
        Table.SelectRows(
            KeepColumns,
            each [LocationKey] <> null and [LocationKey] <> ""
        ),
    DimLocation =
        Table.Distinct(
            NonBlankKeys,
            {"LocationKey"}
        )
in
    DimLocation
