let
    S = int_ValidSales,
    NonBlankKeys =
        Table.SelectRows(
            S,
            each [LocationKey] <> null and [LocationKey] <> ""
        ),
    Grouped =
        Table.Group(
            NonBlankKeys,
            {"LocationKey"},
            {
                {
                    "Attribute Variants",
                    each
                        Table.RowCount(
                            Table.Distinct(
                                Table.SelectColumns(
                                    _,
                                    {
                                        "Country", "Region", "State",
                                        "City", "Postal Code"
                                    }
                                )
                            )
                        ),
                    Int64.Type
                }
            }
        ),
    Conflicts =
        Table.SelectRows(
            Grouped,
            each [Attribute Variants] > 1
        )
in
    Conflicts
