ALTER PROCEDURE usp_LoadFactSalesQuota
AS
BEGIN
    SET NOCOUNT ON;

    WITH SalesQuotaSource AS (
        SELECT
            de.EmployeeKey,
            dd.DateKey,
            dd.CalendarYear,
            dd.CalendarQuarter,
            sq.SalesQuota,
            sq.QuotaDate
            -- select count(1)
        FROM AdventureWorks.Sales.SalesPersonQuotaHistory AS sq
        INNER JOIN AdventureWorks.HumanResources.Employee AS e
            ON sq.BusinessEntityID = e.BusinessEntityID
        INNER JOIN AdventureWorksDW.dbo.DimEmployee AS de
            ON e.NationalIDNumber = de.EmployeeNationalIDAlternateKey
        INNER JOIN AdventureWorksDW.dbo.DimDate AS dd
            ON dd.FullDateAlternateKey = CAST(sq.QuotaDate AS DATE)
        WHERE de.EmployeeKey IS NOT NULL
          AND dd.DateKey IS NOT NULL
    )

    MERGE AdventureWorksDW.dbo.FactSalesQuota AS target
    USING (
        SELECT
            EmployeeKey,
            DateKey,
            CalendarYear,
            CalendarQuarter,
            SalesQuota,
            QuotaDate
        FROM SalesQuotaSource
    ) AS source
    ON target.EmployeeKey = source.EmployeeKey
       AND target.DateKey = source.DateKey
    WHEN NOT MATCHED BY TARGET THEN
        INSERT (
            EmployeeKey,
            DateKey,
            CalendarYear,
            CalendarQuarter,
            SalesAmountQuota,
            [Date]
        )
        VALUES (
            source.EmployeeKey,
            source.DateKey,
            source.CalendarYear,
            source.CalendarQuarter,
            source.SalesQuota,
            source.QuotaDate
        );
END;