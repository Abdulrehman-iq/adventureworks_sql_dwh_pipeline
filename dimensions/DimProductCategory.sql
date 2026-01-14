ALTER   PROCEDURE usp_LoadDimProductCategory
AS
BEGIN
    SET NOCOUNT ON;

    MERGE AdventureWorksDW.dbo.DimProductCategory AS TARGET
    USING (
        SELECT
            pc.ProductCategoryID AS ProductCategoryAlternateKey,
            pc.Name AS EnglishProductCategoryName,
            'Unknown' AS SpanishProductCategoryName,
            'Unknown' AS FrenchProductCategoryName
        FROM AdventureWorks.Production.ProductCategory pc
    ) AS SOURCE
        ON TARGET.ProductCategoryAlternateKey = SOURCE.ProductCategoryAlternateKey
    WHEN MATCHED THEN
        UPDATE SET
            TARGET.EnglishProductCategoryName = SOURCE.EnglishProductCategoryName,
            TARGET.SpanishProductCategoryName = SOURCE.SpanishProductCategoryName,
            TARGET.FrenchProductCategoryName = SOURCE.FrenchProductCategoryName
    WHEN NOT MATCHED BY TARGET THEN
        INSERT (ProductCategoryAlternateKey, EnglishProductCategoryName, SpanishProductCategoryName, FrenchProductCategoryName)
        VALUES (SOURCE.ProductCategoryAlternateKey, SOURCE.EnglishProductCategoryName, SOURCE.SpanishProductCategoryName, SOURCE.FrenchProductCategoryName);
END;