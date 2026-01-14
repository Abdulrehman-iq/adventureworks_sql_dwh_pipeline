ALTER   PROCEDURE usp_LoadDimEmployee
AS
BEGIN
    SET NOCOUNT ON;

    MERGE AdventureWorksDW.dbo.DimEmployee AS TARGET
    USING (
        SELECT
            -1 AS ParentEmployeeKey,
            ISNULL(e.NationalIDNumber, 'Unknown') AS EmployeeNationalIDAlternateKey,
            -1 AS ParentEmployeeNationalIDAlternateKey,
            ISNULL(dst.SalesTerritoryKey, -1) AS SalesTerritoryKey,
            ISNULL(p.FirstName, 'Unknown') AS FirstName,
            ISNULL(p.LastName, 'Unknown') AS LastName,
            ISNULL(p.MiddleName, '') AS MiddleName,
            ISNULL(p.NameStyle, 0) AS NameStyle,
            ISNULL(p.Title, 'Unknown') AS Title,
            ISNULL(e.HireDate, CAST('1900-01-01' AS DATE)) AS HireDate,
            ISNULL(e.BirthDate, CAST('1900-01-01' AS DATE)) AS BirthDate,
            ISNULL(e.LoginID, 'Unknown') AS LoginID,
            ISNULL(ea.EmailAddress, 'Unknown') AS EmailAddress,
            ISNULL(pp.PhoneNumber, 'Unknown') AS Phone,
            ISNULL(e.MaritalStatus, 'Unknown') AS MaritalStatus,
            'Unknown' AS EmergencyContactName,
            'Unknown' AS EmergencyContactPhone,
            ISNULL(e.SalariedFlag, 0) AS SalariedFlag,
            ISNULL(e.Gender, 'Unknown') AS Gender,
            ISNULL(eph.PayFrequency, 0) AS PayFrequency,
            ISNULL(eph.Rate, 0) AS BaseRate,
            ISNULL(e.VacationHours, 0) AS VacationHours,
            ISNULL(e.SickLeaveHours, 0) AS SickLeaveHours,
            ISNULL(e.CurrentFlag, 0) AS CurrentFlag,
            CASE WHEN sp.BusinessEntityID IS NOT NULL THEN 1 ELSE 0 END AS SalesPersonFlag,
            ISNULL(d.Name, 'Unknown') AS DepartmentName,
            ISNULL(edh.StartDate, CAST('1900-01-01' AS DATE)) AS StartDate,
            ISNULL(edh.EndDate, CAST('9999-12-31' AS DATE)) AS EndDate,
            'Unknown' AS Status,
            CONVERT(VARBINARY(MAX), 'Unknown') AS EmployeePhoto
        FROM AdventureWorks.HumanResources.Employee e
        JOIN AdventureWorks.Person.Person p
            ON e.BusinessEntityID = p.BusinessEntityID
        JOIN AdventureWorks.Person.EmailAddress ea
            ON p.BusinessEntityID = ea.BusinessEntityID
        JOIN AdventureWorks.Person.PersonPhone pp
            ON p.BusinessEntityID = pp.BusinessEntityID
        JOIN AdventureWorks.HumanResources.EmployeeDepartmentHistory edh
            ON e.BusinessEntityID = edh.BusinessEntityID AND edh.EndDate IS NULL
        JOIN AdventureWorks.HumanResources.Department d
            ON edh.DepartmentID = d.DepartmentID
        JOIN AdventureWorks.HumanResources.EmployeePayHistory eph
            ON e.BusinessEntityID = eph.BusinessEntityID
            AND eph.RateChangeDate = (
                SELECT MAX(RateChangeDate)
                FROM AdventureWorks.HumanResources.EmployeePayHistory
                WHERE BusinessEntityID = e.BusinessEntityID
            )
        LEFT JOIN AdventureWorks.Sales.SalesPerson sp
            ON e.BusinessEntityID = sp.BusinessEntityID
        LEFT JOIN AdventureWorksDW.dbo.DimSalesTerritory dst
            ON sp.TerritoryID = dst.SalesTerritoryAlternateKey
    ) AS SOURCE
    ON TARGET.EmployeeNationalIDAlternateKey = SOURCE.EmployeeNationalIDAlternateKey
    WHEN NOT MATCHED BY TARGET THEN
        INSERT (
            ParentEmployeeKey,
            EmployeeNationalIDAlternateKey,
            ParentEmployeeNationalIDAlternateKey,
            SalesTerritoryKey,
            FirstName,
            LastName,
            MiddleName,
            NameStyle,
            Title,
            HireDate,
            BirthDate,
            LoginID,
            EmailAddress,
            Phone,
            MaritalStatus,
            EmergencyContactName,
            EmergencyContactPhone,
            SalariedFlag,
            Gender,
            PayFrequency,
            BaseRate,
            VacationHours,
            SickLeaveHours,
            CurrentFlag,
            SalesPersonFlag,
            DepartmentName,
            StartDate,
            EndDate,
            Status,
            EmployeePhoto
        )
        VALUES (
            SOURCE.ParentEmployeeKey,
            SOURCE.EmployeeNationalIDAlternateKey,
            SOURCE.ParentEmployeeNationalIDAlternateKey,
            SOURCE.SalesTerritoryKey,
            SOURCE.FirstName,
            SOURCE.LastName,
            SOURCE.MiddleName,
            SOURCE.NameStyle,
            SOURCE.Title,
            SOURCE.HireDate,
            SOURCE.BirthDate,
            SOURCE.LoginID,
            SOURCE.EmailAddress,
            SOURCE.Phone,
            SOURCE.MaritalStatus,
            SOURCE.EmergencyContactName,
            SOURCE.EmergencyContactPhone,
            SOURCE.SalariedFlag,
            SOURCE.Gender,
            SOURCE.PayFrequency,
            SOURCE.BaseRate,
            SOURCE.VacationHours,
            SOURCE.SickLeaveHours,
            SOURCE.CurrentFlag,
            SOURCE.SalesPersonFlag,
            SOURCE.DepartmentName,
            SOURCE.StartDate,
            SOURCE.EndDate,
            SOURCE.Status,
            SOURCE.EmployeePhoto
        );
END