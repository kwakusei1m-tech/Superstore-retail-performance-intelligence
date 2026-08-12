let
    S = stg_Superstore,
    ValidDates = List.RemoveNulls(S[Order Date]),
    MinOrderDate =
        if List.IsEmpty(ValidDates) then null
        else List.Min(ValidDates),
    MaxOrderDate =
        if List.IsEmpty(ValidDates) then null
        else List.Max(ValidDates),
    Audit =
        #table(
            type table
            [
                RefreshUTC = datetimezone,
                SourcePath = text,
                RowCount = Int64.Type,
                ValidRowCount = Int64.Type,
                MinOrderDate = date,
                MaxOrderDate = date
            ],
            {
                {
                    DateTimeZone.FixedUtcNow(),
                    pSourcePath,
                    Table.RowCount(S),
                    Table.RowCount(
                        Table.SelectRows(S, each [DQ Status] = "PASS")
                    ),
                    MinOrderDate,
                    MaxOrderDate
                }
            }
        )
in
    Audit
