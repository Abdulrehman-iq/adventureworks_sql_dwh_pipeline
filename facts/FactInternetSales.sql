ALTER PROCEDURE usp_LoadFactInternetSales
AS
BEGIN
    SET NOCOUNT ON;

    ;WITH SourceData AS (
        SELECT
            dp.ProductKey,
            ISNULL(ddo.DateKey, -1) AS OrderDateKey,
            ISNULL(ddd.DateKey, -1) AS DueDateKey,
            ISNULL(dds.DateKey, -1) AS ShipDateKey,
            ISNULL(dc.CustomerKey, -1) AS CustomerKey,
            ISNULL(dpr.PromotionKey, -1) AS PromotionKey,
            ISNULL(dcu.CurrencyKey, -1) AS CurrencyKey,
            ISNULL(dst.SalesTerritoryKey, -1) AS SalesTerritoryKey,
            soh.SalesOrderNumber,
            ROW_NUMBER() OVER (PARTITION BY soh.SalesOrderNumber ORDER BY sod.SalesOrderDetailID) AS SalesOrderLineNumber,
            soh.RevisionNumber,
            sod.OrderQty,
            sod.UnitPrice,
            sod.OrderQty * sod.UnitPrice AS ExtendedAmount,
            sod.UnitPriceDiscount AS UnitPriceDiscountPct,
            (sod.UnitPrice * sod.OrderQty * sod.UnitPriceDiscount) AS DiscountAmount,
            ISNULL(dp.StandardCost, 0) AS ProductStandardCost,
            ISNULL(dp.StandardCost * sod.OrderQty, 0) AS TotalProductCost,
            (sod.OrderQty * sod.UnitPrice) - (sod.OrderQty * sod.UnitPrice * sod.UnitPriceDiscount) AS SalesAmount,
            soh.TaxAmt,
            soh.Freight,
            ISNULL(sod.CarrierTrackingNumber, 'Unknown') AS CarrierTrackingNumber,
            ISNULL(soh.PurchaseOrderNumber, 'Unknown') AS CustomerPONumber,
            soh.OrderDate,
            soh.DueDate,
            soh.ShipDate
        FROM AdventureWorks.Sales.SalesOrderDetail AS sod
        INNER JOIN AdventureWorks.Sales.SalesOrderHeader AS soh
            ON sod.SalesOrderID = soh.SalesOrderID
        LEFT JOIN AdventureWorks.Production.Product AS p
            ON sod.ProductID = p.ProductID
        LEFT JOIN AdventureWorksDW.dbo.DimProduct AS dp
            ON dp.ProductAlternateKey = p.ProductNumber
        LEFT JOIN AdventureWorksDW.dbo.DimCustomer AS dc
            ON dc.CustomerAlternateKey = soh.CustomerID
        LEFT JOIN AdventureWorks.Sales.CurrencyRate AS cr
            ON soh.CurrencyRateID = cr.CurrencyRateID
        LEFT JOIN AdventureWorksDW.dbo.DimCurrency AS dcu
            ON dcu.CurrencyAlternateKey = cr.FromCurrencyCode
        LEFT JOIN AdventureWorksDW.dbo.DimPromotion AS dpr
            ON dpr.PromotionAlternateKey = sod.SpecialOfferID
        LEFT JOIN AdventureWorksDW.dbo.DimSalesTerritory AS dst
            ON dst.SalesTerritoryAlternateKey = soh.TerritoryID
        LEFT JOIN AdventureWorksDW.dbo.DimDate AS ddo
            ON ddo.FullDateAlternateKey = CAST(soh.OrderDate AS DATE)
        LEFT JOIN AdventureWorksDW.dbo.DimDate AS ddd
            ON ddd.FullDateAlternateKey = CAST(soh.DueDate AS DATE)
        LEFT JOIN AdventureWorksDW.dbo.DimDate AS dds
            ON dds.FullDateAlternateKey = CAST(soh.ShipDate AS DATE)
    )
    MERGE AdventureWorksDW.dbo.FactInternetSales AS target
    USING (
        SELECT * FROM SourceData
    ) AS source
    ON target.SalesOrderNumber = source.SalesOrderNumber
       AND target.SalesOrderLineNumber = source.SalesOrderLineNumber
    WHEN NOT MATCHED BY TARGET THEN
        INSERT (
            ProductKey,
            OrderDateKey,
            DueDateKey,
            ShipDateKey,
            CustomerKey,
            PromotionKey,
            CurrencyKey,
            SalesTerritoryKey,
            SalesOrderNumber,
            SalesOrderLineNumber,
            RevisionNumber,
            OrderQuantity,
            UnitPrice,
            ExtendedAmount,
            UnitPriceDiscountPct,
            DiscountAmount,
            ProductStandardCost,
            TotalProductCost,
            SalesAmount,
            TaxAmt,
            Freight,
            CarrierTrackingNumber,
            CustomerPONumber,
            OrderDate,
            DueDate,
            ShipDate
        )
        VALUES (
            source.ProductKey,
            source.OrderDateKey,
            source.DueDateKey,
            source.ShipDateKey,
            source.CustomerKey,
            source.PromotionKey,
            source.CurrencyKey,
            source.SalesTerritoryKey,
            source.SalesOrderNumber,
            source.SalesOrderLineNumber,
            source.RevisionNumber,
            source.OrderQty,
            source.UnitPrice,
            source.ExtendedAmount,
            source.UnitPriceDiscountPct,
            source.DiscountAmount,
            source.ProductStandardCost,
            source.TotalProductCost,
            source.SalesAmount,
            source.TaxAmt,
            source.Freight,
            source.CarrierTrackingNumber,
            source.CustomerPONumber,
            source.OrderDate,
            source.DueDate,
            source.ShipDate
        );
END;