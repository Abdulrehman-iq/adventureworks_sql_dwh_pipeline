ALTER PROCEDURE usp_LoadFactSurveyResponse
AS
BEGIN
    SET NOCOUNT ON;

    MERGE AdventureWorksDW.dbo.FactSurveyResponse AS target
    USING (
        SELECT TOP 500
            dd.DateKey,
            dc.CustomerKey,
            dpc.ProductCategoryKey,
            dpc.EnglishProductCategoryName,
            dps.ProductSubcategoryKey,
            dps.EnglishProductSubcategoryName,
            dd.FullDateAlternateKey AS [Date]
        FROM AdventureWorksDW.dbo.DimCustomer dc
        INNER JOIN AdventureWorksDW.dbo.DimProductSubcategory dps 
            ON dps.ProductSubcategoryKey IS NOT NULL
        INNER JOIN AdventureWorksDW.dbo.DimProductCategory dpc 
            ON dps.ProductCategoryKey = dpc.ProductCategoryKey
        INNER JOIN AdventureWorksDW.dbo.DimDate dd
            ON dd.CalendarYear = 2025
        WHERE dc.CustomerKey IS NOT NULL
          AND dd.DateKey IS NOT NULL
          AND dpc.ProductCategoryKey IS NOT NULL
          AND dps.ProductSubcategoryKey IS NOT NULL
    ) AS source
    ON target.DateKey = source.DateKey
       AND target.CustomerKey = source.CustomerKey
       AND target.ProductCategoryKey = source.ProductCategoryKey
       AND target.ProductSubcategoryKey = source.ProductSubcategoryKey
    WHEN NOT MATCHED BY TARGET THEN
        INSERT (
            DateKey,
            CustomerKey,
            ProductCategoryKey,
            EnglishProductCategoryName,
            ProductSubcategoryKey,
            EnglishProductSubcategoryName,
            [Date]
        )
        VALUES (
            source.DateKey,
            source.CustomerKey,
            source.ProductCategoryKey,
            source.EnglishProductCategoryName,
            source.ProductSubcategoryKey,
            source.EnglishProductSubcategoryName,
            source.[Date]
        );
END;