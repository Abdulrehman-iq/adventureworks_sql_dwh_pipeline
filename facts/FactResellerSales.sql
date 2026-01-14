ALTER PROCEDURE usp_LoadFactResellerSales
AS
BEGIN
    SET NOCOUNT ON;

    MERGE AdventureWorksDW.dbo.FactResellerSales AS TARGET
    USING (
        SELECT
            ISNULL(dp.ProductKey, -1) AS ProductKey,
            ISNULL(dd_order.DateKey, -1) AS OrderDateKey,
            ISNULL(dd_due.DateKey, -1) AS DueDateKey,
            ISNULL(dd_ship.DateKey, -1) AS ShipDateKey,
            ISNULL(dr.ResellerKey, -1) AS ResellerKey,
            ISNULL(de.EmployeeKey, -1) AS EmployeeKey,
            ISNULL(dpr.PromotionKey, -1) AS PromotionKey,
            ISNULL(dc.CurrencyKey, -1) AS CurrencyKey,
            ISNULL(dst.SalesTerritoryKey, -1) AS SalesTerritoryKey,
            soh.SalesOrderNumber,
            sod.SalesOrderDetailID AS SalesOrderLineNumber,
            soh.RevisionNumber,
            sod.OrderQty AS OrderQuantity,
            sod.UnitPrice,
            sod.UnitPrice * sod.OrderQty AS ExtendedAmount,
            ISNULL(so.DiscountPct, 0) AS UnitPriceDiscountPct,
            sod.UnitPrice * sod.OrderQty * ISNULL(so.DiscountPct, 0) AS DiscountAmount,
            ISNULL(p.StandardCost, 0) AS ProductStandardCost,
            ISNULL(p.StandardCost, 0) * sod.OrderQty AS TotalProductCost,
            sod.UnitPrice * sod.OrderQty * (1 - ISNULL(so.DiscountPct, 0)) AS SalesAmount,
            ISNULL(soh.TaxAmt, 0) AS TaxAmt,
            ISNULL(soh.Freight, 0) AS Freight,
            ISNULL(sod.CarrierTrackingNumber, 'Unknown') AS CarrierTrackingNumber,
            ISNULL(soh.PurchaseOrderNumber, 'Unknown') AS CustomerPONumber,
            soh.OrderDate,
            soh.DueDate,
            soh.ShipDate
            -- select count(1)
        FROM AdventureWorks.Sales.SalesOrderDetail sod
        INNER JOIN AdventureWorks.Sales.SalesOrderHeader soh
            ON sod.SalesOrderID = soh.SalesOrderID
        LEFT JOIN AdventureWorks.Sales.SpecialOffer so
            ON sod.SpecialOfferID = so.SpecialOfferID
        LEFT JOIN AdventureWorks.Production.Product p
            ON sod.ProductID = p.ProductID
        LEFT JOIN AdventureWorks.Sales.SalesPerson sp
            ON soh.SalesPersonID = sp.BusinessEntityID
        LEFT JOIN AdventureWorks.HumanResources.Employee e
            ON sp.BusinessEntityID = e.BusinessEntityID
        LEFT JOIN AdventureWorks.Sales.CurrencyRate cr
            ON soh.CurrencyRateID = cr.CurrencyRateID
        LEFT JOIN AdventureWorks.Sales.Customer c
            ON soh.CustomerID = c.CustomerID
        LEFT JOIN AdventureWorks.Sales.Store s
            ON c.StoreID = s.BusinessEntityID
        LEFT JOIN AdventureWorksDW.dbo.DimReseller dr
            ON dr.ResellerAlternateKey = s.BusinessEntityID
        LEFT JOIN AdventureWorksDW.dbo.DimProduct dp
            ON dp.ProductAlternateKey = p.ProductNumber
        LEFT JOIN AdventureWorksDW.dbo.DimEmployee de
            ON de.EmployeeNationalIDAlternateKey = e.NationalIDNumber
        LEFT JOIN AdventureWorksDW.dbo.DimPromotion dpr
            ON dpr.PromotionAlternateKey = so.SpecialOfferID
        LEFT JOIN AdventureWorksDW.dbo.DimCurrency dc
            ON dc.CurrencyAlternateKey = cr.ToCurrencyCode
        LEFT JOIN AdventureWorksDW.dbo.DimSalesTerritory dst
            ON dst.SalesTerritoryAlternateKey = sp.TerritoryID
        LEFT JOIN AdventureWorksDW.dbo.DimDate dd_order
            ON dd_order.FullDateAlternateKey = soh.OrderDate
        LEFT JOIN AdventureWorksDW.dbo.DimDate dd_due
            ON dd_due.FullDateAlternateKey = soh.DueDate
        LEFT JOIN AdventureWorksDW.dbo.DimDate dd_ship
            ON dd_ship.FullDateAlternateKey = soh.ShipDate
    ) AS SOURCE
    ON TARGET.SalesOrderNumber = SOURCE.SalesOrderNumber
       AND TARGET.SalesOrderLineNumber = SOURCE.SalesOrderLineNumber

    WHEN MATCHED THEN
        UPDATE SET
            TARGET.SalesAmount = SOURCE.SalesAmount,
            TARGET.TotalProductCost = SOURCE.TotalProductCost,
            TARGET.DiscountAmount = SOURCE.DiscountAmount,
            TARGET.TaxAmt = SOURCE.TaxAmt,
            TARGET.Freight = SOURCE.Freight

    WHEN NOT MATCHED THEN
        INSERT (
            ProductKey, OrderDateKey, DueDateKey, ShipDateKey,
            ResellerKey, EmployeeKey, PromotionKey, CurrencyKey, SalesTerritoryKey,
            SalesOrderNumber, SalesOrderLineNumber, RevisionNumber,
            OrderQuantity, UnitPrice, ExtendedAmount, UnitPriceDiscountPct,
            DiscountAmount, ProductStandardCost, TotalProductCost, SalesAmount,
            TaxAmt, Freight, CarrierTrackingNumber, CustomerPONumber,
            OrderDate, DueDate, ShipDate
        )
        VALUES (
            SOURCE.ProductKey, SOURCE.OrderDateKey, SOURCE.DueDateKey, SOURCE.ShipDateKey,
            SOURCE.ResellerKey, SOURCE.EmployeeKey, SOURCE.PromotionKey, SOURCE.CurrencyKey, SOURCE.SalesTerritoryKey,
            SOURCE.SalesOrderNumber, SOURCE.SalesOrderLineNumber, SOURCE.RevisionNumber,
            SOURCE.OrderQuantity, SOURCE.UnitPrice, SOURCE.ExtendedAmount, SOURCE.UnitPriceDiscountPct,
            SOURCE.DiscountAmount, SOURCE.ProductStandardCost, SOURCE.TotalProductCost, SOURCE.SalesAmount,
            SOURCE.TaxAmt, SOURCE.Freight, SOURCE.CarrierTrackingNumber, SOURCE.CustomerPONumber,
            SOURCE.OrderDate, SOURCE.DueDate, SOURCE.ShipDate
        );
END;