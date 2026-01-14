ALTER PROCEDURE usp_LoadFactCurrencyRate
AS
BEGIN
    SET NOCOUNT ON;

    MERGE AdventureWorksDW.dbo.FactCurrencyRate AS target
    USING (
        SELECT
            dc.CurrencyKey,
            dd.DateKey,
            cr.AverageRate,
            cr.EndOfDayRate,
            cr.CurrencyRateDate AS [Date]
        FROM AdventureWorks.Sales.CurrencyRate cr
        INNER JOIN AdventureWorksDW.dbo.DimCurrency dc
            ON cr.ToCurrencyCode = dc.CurrencyAlternateKey
        INNER JOIN AdventureWorksDW.dbo.DimDate dd
            ON cr.CurrencyRateDate = dd.FullDateAlternateKey
    ) AS source
    ON target.CurrencyKey = source.CurrencyKey AND target.DateKey = source.DateKey
    WHEN NOT MATCHED BY TARGET THEN
        INSERT (
            CurrencyKey,
            DateKey,
            AverageRate,
            EndOfDayRate,
            [Date]
        )
        VALUES (
            source.CurrencyKey,
            source.DateKey,
            source.AverageRate,
            source.EndOfDayRate,
            source.[Date]
        );
END