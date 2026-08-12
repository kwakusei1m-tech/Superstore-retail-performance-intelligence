let
    S = int_ValidSales,
    Grouped =
        Table.Group(
            S,
            {"Customer ID"},
            {
                {
                    "Attribute Variants",
                    each
                        Table.RowCount(
                            Table.Distinct(
                                Table.SelectColumns(
                                    _,
                                    {"Customer Name", "Segment"}
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
