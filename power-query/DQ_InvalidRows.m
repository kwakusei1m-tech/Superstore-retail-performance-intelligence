let
    Source = stg_Superstore,
    InvalidRows =
        Table.SelectRows(
            Source,
            each [DQ Status] = "FAIL"
        )
in
    InvalidRows
