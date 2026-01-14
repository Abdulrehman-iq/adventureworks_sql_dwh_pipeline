ALTER PROCEDURE usp_LoadDimCurrency
AS
BEGIN
    SET NOCOUNT ON;

    -- Merge real currency data
    MERGE AdventureWorksDW.dbo.DimCurrency AS TARGET
    USING (
        SELECT 
            LEFT(c.CurrencyCode, 3) AS CurrencyAlternateKey,
            c.Name AS CurrencyName
        FROM AdventureWorks.Sales.Currency c
    ) AS SOURCE
    ON TARGET.CurrencyAlternateKey = SOURCE.CurrencyAlternateKey

    WHEN MATCHED THEN
        UPDATE SET
            TARGET.CurrencyName = SOURCE.CurrencyName

    WHEN NOT MATCHED BY TARGET THEN
        INSERT (CurrencyAlternateKey, CurrencyName)
        VALUES (SOURCE.CurrencyAlternateKey, SOURCE.CurrencyName);

END;