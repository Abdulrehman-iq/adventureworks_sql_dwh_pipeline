ALTER PROCEDURE usp_LoadFactCallCenter
AS
BEGIN
    SET NOCOUNT ON;

    MERGE AdventureWorksDW.dbo.FactCallCenter AS target
    USING (
        SELECT
            dd.DateKey,
            'Unknown' AS WageType,
            'Unknown' AS Shift,
            0 AS LevelOneOperators,
            0 AS LevelTwoOperators,
            0 AS TotalOperators,
            0 AS Calls,
            0 AS AutomaticResponses,
            0 AS Orders,
            0 AS IssuesRaised,
            0.0 AS AverageTimePerIssue,
            0.0 AS ServiceGrade,
            dd.FullDateAlternateKey AS [Date]
        FROM AdventureWorksDW.dbo.DimDate dd
    ) AS source
    ON target.DateKey = source.DateKey
    WHEN NOT MATCHED BY TARGET THEN
        INSERT (
            DateKey,
            WageType,
            Shift,
            LevelOneOperators,
            LevelTwoOperators,
            TotalOperators,
            Calls,
            AutomaticResponses,
            Orders,
            IssuesRaised,
            AverageTimePerIssue,
            ServiceGrade,
            [Date]
        )
        VALUES (
            source.DateKey,
            source.WageType,
            source.Shift,
            source.LevelOneOperators,
            source.LevelTwoOperators,
            source.TotalOperators,
            source.Calls,
            source.AutomaticResponses,
            source.Orders,
            source.IssuesRaised,
            source.AverageTimePerIssue,
            source.ServiceGrade,
            source.[Date]
        );
END