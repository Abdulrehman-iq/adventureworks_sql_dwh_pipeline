ALTER PROCEDURE usp_LoadDimScenarios
AS
BEGIN
    SET NOCOUNT ON;

    MERGE AdventureWorksDW.dbo.DimScenario AS TARGET
    USING (
        VALUES
            ('Actual'),
            ('Budget'),
            ('Forecast'),
            ('Expense')
    ) AS SOURCE (ScenarioName)
        ON TARGET.ScenarioName = SOURCE.ScenarioName
When Matched Then 
Update SET
Target.ScenarioName=Source.ScenarioName

    WHEN NOT MATCHED BY TARGET THEN
        INSERT (ScenarioName)
        VALUES (SOURCE.ScenarioName);
END;