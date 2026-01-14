ALTER PROCEDURE usp_LoadDimDepartmentGroup
AS
BEGIN
    SET NOCOUNT ON;
--
    MERGE AdventureWorksDW.dbo.DimDepartmentGroup AS TARGET
    USING (
        SELECT DISTINCT 
            -1 AS ParentDepartmentGroupKey,
            d.GroupName AS DepartmentGroupName
        FROM AdventureWorks.HumanResources.Department d
    ) AS SOURCE
        ON TARGET.DepartmentGroupName = SOURCE.DepartmentGroupName
    WHEN NOT MATCHED BY TARGET THEN
        INSERT (ParentDepartmentGroupKey, DepartmentGroupName)
        VALUES (SOURCE.ParentDepartmentGroupKey, SOURCE.DepartmentGroupName);
END