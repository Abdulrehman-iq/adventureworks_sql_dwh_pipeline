ALTER   PROCEDURE usp_LoadDimPromotion
AS
BEGIN
    SET NOCOUNT ON;

    MERGE AdventureWorksDW.dbo.DimPromotion AS TARGET
    USING (
        SELECT 
            so.SpecialOfferID AS PromotionAlternateKey,
            ISNULL(so.Description, 'Unknown') AS EnglishPromotionName,
            'Unknown' AS SpanishPromotionName,
            'Unknown' AS FrenchPromotionName,
            ISNULL(so.DiscountPct, 0) AS DiscountPct,
            ISNULL(so.[Type], 'Unknown') AS EnglishPromotionType,
            'Unknown' AS SpanishPromotionType,
            'Unknown' AS FrenchPromotionType,
            ISNULL(so.Category, 'Unknown') AS EnglishPromotionCategory,
            'Unknown' AS SpanishPromotionCategory,
            'Unknown' AS FrenchPromotionCategory,
            ISNULL(so.StartDate, CAST('1900-01-01' AS DATE)) AS StartDate,
            ISNULL(so.EndDate, CAST('9999-12-31' AS DATE)) AS EndDate,
            ISNULL(so.MinQty, 0) AS MinQty,
            ISNULL(so.MaxQty, -1) AS MaxQty
        FROM AdventureWorks.Sales.SpecialOffer so
    ) AS SOURCE
        ON TARGET.PromotionAlternateKey = SOURCE.PromotionAlternateKey
    WHEN MATCHED THEN
        UPDATE SET
            TARGET.EnglishPromotionName = SOURCE.EnglishPromotionName,
            TARGET.SpanishPromotionName = SOURCE.SpanishPromotionName,
            TARGET.FrenchPromotionName = SOURCE.FrenchPromotionName,
            TARGET.DiscountPct = SOURCE.DiscountPct,
            TARGET.EnglishPromotionType = SOURCE.EnglishPromotionType,
            TARGET.SpanishPromotionType = SOURCE.SpanishPromotionType,
            TARGET.FrenchPromotionType = SOURCE.FrenchPromotionType,
            TARGET.EnglishPromotionCategory = SOURCE.EnglishPromotionCategory,
            TARGET.SpanishPromotionCategory = SOURCE.SpanishPromotionCategory,
            TARGET.FrenchPromotionCategory = SOURCE.FrenchPromotionCategory,
            TARGET.StartDate = SOURCE.StartDate,
            TARGET.EndDate = SOURCE.EndDate,
            TARGET.MinQty = SOURCE.MinQty,
            TARGET.MaxQty = SOURCE.MaxQty
    WHEN NOT MATCHED BY TARGET THEN
        INSERT (
            PromotionAlternateKey, EnglishPromotionName, SpanishPromotionName, FrenchPromotionName,
            DiscountPct, EnglishPromotionType, SpanishPromotionType, FrenchPromotionType,
            EnglishPromotionCategory, SpanishPromotionCategory, FrenchPromotionCategory,
            StartDate, EndDate, MinQty, MaxQty
        )
        VALUES (
            SOURCE.PromotionAlternateKey, SOURCE.EnglishPromotionName, SOURCE.SpanishPromotionName, SOURCE.FrenchPromotionName,
            SOURCE.DiscountPct, SOURCE.EnglishPromotionType, SOURCE.SpanishPromotionType, SOURCE.FrenchPromotionType,
            SOURCE.EnglishPromotionCategory, SOURCE.SpanishPromotionCategory, SOURCE.FrenchPromotionCategory,
            SOURCE.StartDate, SOURCE.EndDate, SOURCE.MinQty, SOURCE.MaxQty
        );
END;