CREATE   PROCEDURE usp_LoadFactFinance
AS
BEGIN
    SET NOCOUNT ON;

    ;WITH
    -- Step 1: Rank each dimension so we can join by row number
    Accounts AS (
        SELECT AccountKey, ROW_NUMBER() OVER (ORDER BY AccountKey) AS rn
        FROM AdventureWorksDW.dbo.DimAccount
    ),
    Departments AS (
        SELECT DepartmentGroupKey, ROW_NUMBER() OVER (ORDER BY DepartmentGroupKey) AS rn
        FROM AdventureWorksDW.dbo.DimDepartmentGroup
    ),
    Organizations AS (
        SELECT OrganizationKey, ROW_NUMBER() OVER (ORDER BY OrganizationKey) AS rn
        FROM AdventureWorksDW.dbo.DimOrganization
    ),
    Scenarios AS (
        SELECT ScenarioKey, ROW_NUMBER() OVER (ORDER BY ScenarioKey) AS rn
        FROM AdventureWorksDW.dbo.DimScenario
    ),
    Dates AS (
        SELECT DateKey, FullDateAlternateKey AS [Date],
               ROW_NUMBER() OVER (ORDER BY DateKey) AS rn
        FROM AdventureWorksDW.dbo.DimDate
        WHERE CalendarYear = 2025
    )

    INSERT INTO AdventureWorksDW.dbo.FactFinance
    (
        DateKey,
        OrganizationKey,
        DepartmentGroupKey,
        ScenarioKey,
        AccountKey,
        Amount,
        [Date]
    )
    SELECT
        d.DateKey,
        ISNULL(o.OrganizationKey, -1),
        ISNULL(dep.DepartmentGroupKey, -1),
        ISNULL(s.ScenarioKey, -1),
        ISNULL(a.AccountKey, -1),
        CAST(RAND(CHECKSUM(NEWID())) * 100000 - 50000 AS DECIMAL(18,2)) AS Amount,
        d.[Date]
    FROM Dates d
    LEFT JOIN Accounts a ON a.rn = d.rn
    LEFT JOIN Departments dep ON dep.rn = d.rn
    LEFT JOIN Organizations o ON o.rn = d.rn
    LEFT JOIN Scenarios s ON s.rn = d.rn
    WHERE NOT EXISTS (
        SELECT 1 FROM AdventureWorksDW.dbo.FactFinance f
        WHERE f.DateKey = d.DateKey
          AND f.AccountKey = a.AccountKey
          AND f.OrganizationKey = o.OrganizationKey
          AND f.DepartmentGroupKey = dep.DepartmentGroupKey
          AND f.ScenarioKey = s.ScenarioKey
    );
END;