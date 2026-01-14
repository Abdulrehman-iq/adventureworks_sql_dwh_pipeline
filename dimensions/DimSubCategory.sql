ALTER   PROCEDURE usp_LoadDimProductSubCategory
AS
BEGIN
    SET NOCOUNT ON;

    MERGE AdventureWorksDW.dbo.DimProductSubcategory AS TARGET
    USING (
        SELECT 
            ps.ProductSubcategoryID AS ProductSubcategoryAlternateKey,
            ISNULL(ps.Name, 'Unknown') AS EnglishProductSubcategoryName,
            'Unknown' AS SpanishProductSubcategoryName,
            'Unknown' AS FrenchProductSubcategoryName,
            ISNULL(dpc.ProductCategoryKey, -1) AS ProductCategoryKey
        FROM AdventureWorks.Production.ProductSubcategory ps
        JOIN AdventureWorksDW.dbo.DimProductCategory dpc 
            ON ps.ProductCategoryID = dpc.ProductCategoryAlternateKey
    ) AS SOURCE
        ON TARGET.ProductSubcategoryAlternateKey = SOURCE.ProductSubcategoryAlternateKey
    WHEN MATCHED THEN
        UPDATE SET
            TARGET.EnglishProductSubcategoryName = SOURCE.EnglishProductSubcategoryName,
            TARGET.SpanishProductSubcategoryName = SOURCE.SpanishProductSubcategoryName,
            TARGET.FrenchProductSubcategoryName = SOURCE.FrenchProductSubcategoryName,
            TARGET.ProductCategoryKey = SOURCE.ProductCategoryKey
    WHEN NOT MATCHED BY TARGET THEN
        INSERT (ProductSubcategoryAlternateKey, EnglishProductSubcategoryName, SpanishProductSubcategoryName, FrenchProductSubcategoryName, ProductCategoryKey)
        VALUES (SOURCE.ProductSubcategoryAlternateKey, SOURCE.EnglishProductSubcategoryName, SOURCE.SpanishProductSubcategoryName, SOURCE.FrenchProductSubcategoryName, SOURCE.ProductCategoryKey);
END;