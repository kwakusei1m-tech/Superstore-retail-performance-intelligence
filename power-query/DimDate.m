let
    Source = int_ValidSales,

    OrderDates =
        List.RemoveNulls(
            List.Transform(
                Table.Column(Source, "Order Date"),
                each try Date.From(_) otherwise null
            )
        ),

    ShipDates =
        List.RemoveNulls(
            List.Transform(
                Table.Column(Source, "Ship Date"),
                each try Date.From(_) otherwise null
            )
        ),

    ValidDates = List.Combine({OrderDates, ShipDates}),

    MinDate =
        if List.IsEmpty(ValidDates) then #date(2014, 1, 1)
        else Date.StartOfYear(List.Min(ValidDates)),

    MaxDate =
        if List.IsEmpty(ValidDates) then #date(2014, 12, 31)
        else Date.EndOfYear(List.Max(ValidDates)),

    DayCount = Duration.Days(MaxDate - MinDate) + 1,

    DateList =
        List.Dates(
            MinDate,
            DayCount,
            #duration(1, 0, 0, 0)
        ),

    ToTable =
        Table.FromList(
            DateList,
            Splitter.SplitByNothing(),
            {"Date"},
            null,
            ExtraValues.Error
        ),

    Typed = Table.TransformColumnTypes(ToTable, {{"Date", type date}}),

    AddYear =
        Table.AddColumn(
            Typed,
            "Year",
            each Date.Year([Date]),
            Int64.Type
        ),

    AddQuarterNo =
        Table.AddColumn(
            AddYear,
            "Quarter No",
            each Date.QuarterOfYear([Date]),
            Int64.Type
        ),

    AddQuarter =
        Table.AddColumn(
            AddQuarterNo,
            "Quarter",
            each "Q" & Text.From([Quarter No]),
            type text
        ),

    AddMonthNo =
        Table.AddColumn(
            AddQuarter,
            "Month No",
            each Date.Month([Date]),
            Int64.Type
        ),

    AddMonth =
        Table.AddColumn(
            AddMonthNo,
            "Month",
            each Date.ToText([Date], "MMM", "en-US"),
            type text
        ),

    AddMonthName =
        Table.AddColumn(
            AddMonth,
            "Month Name",
            each Date.ToText([Date], "MMMM", "en-US"),
            type text
        ),

    AddYearMonth =
        Table.AddColumn(
            AddMonthName,
            "Year Month",
            each Date.ToText([Date], "yyyy-MM", "en-US"),
            type text
        ),

    AddYearMonthSort =
        Table.AddColumn(
            AddYearMonth,
            "Year Month Sort",
            each [Year] * 100 + [Month No],
            Int64.Type
        ),

    AddWeekdayNo =
        Table.AddColumn(
            AddYearMonthSort,
            "Weekday No",
            each Date.DayOfWeek([Date], Day.Monday) + 1,
            Int64.Type
        ),

    AddWeekday =
        Table.AddColumn(
            AddWeekdayNo,
            "Weekday",
            each Date.ToText([Date], "ddd", "en-US"),
            type text
        ),

    ReorderedColumns =
        Table.ReorderColumns(
            AddWeekday,
            {
                "Date", "Year", "Quarter", "Quarter No",
                "Month", "Month Name", "Month No",
                "Year Month", "Year Month Sort",
                "Weekday", "Weekday No"
            }
        )
in
    ReorderedColumns
