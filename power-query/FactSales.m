let
    Source = int_ValidSales,
    KeepColumns =
        Table.SelectColumns(
            Source,
            {
                "Row ID", "LineKey", "Order ID",
                "Order Date", "Ship Date", "Ship Mode",
                "Customer ID", "Product ID", "LocationKey",
                "Sales", "Quantity", "Discount", "Profit",
                "Ship Days", "Profit Status", "Discount Band",
                "Sales Outlier"
            }
        )
in
    KeepColumns
