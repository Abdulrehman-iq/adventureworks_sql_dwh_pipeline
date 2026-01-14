ALTER PROCEDURE usp_LoadNewFactCurrencyRate
AS
BEGIN
    SET NOCOUNT ON;

    WITH CurrencyRateSource AS (
        SELECT
            cr.AverageRate,
            cr.EndOfDayRate,
            cr.FromCurrencyCode AS CurrencyID,
            cr.CurrencyRateDate AS CurrencyDate,
            dc.CurrencyKey,
            dd.DateKey
            -- select count(1)
        FROM AdventureWorks.Sales.CurrencyRate cr
        INNER JOIN AdventureWorksDW.dbo.DimCurrency dc
            ON dc.CurrencyAlternateKey = cr.FromCurrencyCode
        INNER JOIN AdventureWorksDW.dbo.DimDate dd
            ON dd.FullDateAlternateKey = CAST(cr.CurrencyRateDate AS DATE)
    )

    MERGE AdventureWorksDW.dbo.NewFactCurrencyRate AS target
    USING (
        SELECT
            AverageRate,
            CurrencyID,
            CurrencyDate,
            EndOfDayRate,
            CurrencyKey,
            DateKey
        FROM CurrencyRateSource
    ) AS source
    ON target.CurrencyKey = source.CurrencyKey
       AND target.DateKey = source.DateKey
    WHEN NOT MATCHED BY TARGET THEN
        INSERT (
            AverageRate,
            CurrencyID,
            CurrencyDate,
            EndOfDayRate,
            CurrencyKey,
            DateKey
        )
        VALUES (
            source.AverageRate,
            source.CurrencyID,
            source.CurrencyDate,
            source.EndOfDayRate,
            source.CurrencyKey,
            source.DateKey
        );
END;