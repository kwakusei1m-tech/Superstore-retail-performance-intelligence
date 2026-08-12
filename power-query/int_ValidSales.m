let
    Source = stg_Superstore,
    ValidRows =
        Table.SelectRows(
            Source,
            each [DQ Status] = "PASS"
        )
in
    ValidRows
