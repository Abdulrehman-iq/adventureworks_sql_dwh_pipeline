ALTER   PROCEDURE usp_LoadDimCustomer
AS
BEGIN
    SET NOCOUNT ON;

    MERGE AdventureWorksDW.dbo.DimCustomer AS target
    USING (
        SELECT
            ISNULL(dg.GeographyKey, -1) AS GeographyKey,
            c.CustomerID AS CustomerAlternateKey,
            ISNULL(p.Title, 'Unknown') AS Title,
            ISNULL(p.FirstName, 'Unknown') AS FirstName,
            ISNULL(p.MiddleName, 'Unknown') AS MiddleName,
            ISNULL(p.LastName, 'Unknown') AS LastName,
            ISNULL(p.NameStyle, 0) AS NameStyle,
            e.BirthDate,
            ISNULL(e.MaritalStatus, 'Unknown') AS MaritalStatus,
            ISNULL(p.Suffix, 'Unknown') AS Suffix,
            ISNULL(e.Gender, 'Unknown') AS Gender,
            ISNULL(ea.EmailAddress, 'Unknown') AS EmailAddress,
            CASE
                WHEN eph.PayFrequency = 1 THEN eph.Rate
                WHEN eph.PayFrequency = 2 THEN eph.Rate * 40 * 50
                ELSE 0
            END AS YearlyIncome,
            0 AS TotalChildren,
            0 AS NumberChildrenAtHome,
            'Unknown' AS EnglishEducation,
            'Unknown' AS SpanishEducation,
            'Unknown' AS FrenchEducation,
            'Unknown' AS EnglishOccupation,
            'Unknown' AS SpanishOccupation,
            'Unknown' AS FrenchOccupation,
            0 AS HouseOwnerFlag,
            0 AS NumberCarsOwned,
            ISNULL(hmd.AddressLine1, 'Unknown') AS AddressLine1,
            ISNULL(ofcd.AddressLine1, 'Unknown') AS AddressLine2,
            ISNULL(pp.PhoneNumber, 'Unknown') AS Phone,
            pd.PurchaseDate AS DateFirstPurchase,
            'Unknown' AS CommuteDistance
            -- SELECT COUNT(1)
        FROM AdventureWorks.Sales.Customer c
        LEFT JOIN AdventureWorks.Person.Person p 
            ON c.PersonID = p.BusinessEntityID
        LEFT JOIN (
            SELECT 
                ea.BusinessEntityID,
                MIN(ea.EmailAddress) AS EmailAddress
            FROM AdventureWorks.Person.EmailAddress ea
            GROUP BY ea.BusinessEntityID
        ) ea 
            ON p.BusinessEntityID = ea.BusinessEntityID
        LEFT JOIN (
            SELECT 
                ph.BusinessEntityID,
                MIN(ph.PhoneNumber) AS PhoneNumber
            FROM AdventureWorks.Person.PersonPhone ph
            GROUP BY ph.BusinessEntityID
        ) pp 
            ON p.BusinessEntityID = pp.BusinessEntityID
        LEFT JOIN AdventureWorks.Person.BusinessEntityAddress hma
            ON p.BusinessEntityID = hma.BusinessEntityID AND hma.AddressTypeID = 2 
        LEFT JOIN AdventureWorks.Person.Address hmd 
            ON hma.AddressID = hmd.AddressID
        LEFT JOIN AdventureWorks.Person.BusinessEntityAddress ofc
            ON p.BusinessEntityID = ofc.BusinessEntityID AND ofc.AddressTypeID = 3 
        LEFT JOIN AdventureWorks.Person.Address ofcd 
            ON ofc.AddressID = ofcd.AddressID
        LEFT JOIN AdventureWorks.HumanResources.Employee e 
            ON e.BusinessEntityID = p.BusinessEntityID
        LEFT JOIN AdventureWorks.HumanResources.EmployeePayHistory eph 
            ON e.BusinessEntityID = eph.BusinessEntityID
        LEFT JOIN AdventureWorks.Person.StateProvince sp 
            ON hmd.StateProvinceID = sp.StateProvinceID
        LEFT JOIN AdventureWorks.Person.CountryRegion cr
            ON sp.CountryRegionCode = cr.CountryRegionCode
        LEFT JOIN (
            SELECT 
                MIN(GeographyKey) AS GeographyKey,
                City,
                StateProvinceCode,
                CountryRegionCode,
                PostalCode
            FROM AdventureWorksDW.dbo.DimGeography
            GROUP BY City, StateProvinceCode, CountryRegionCode, PostalCode
        ) dg 
            ON hmd.City = dg.City
           AND sp.StateProvinceCode = dg.StateProvinceCode
           AND cr.CountryRegionCode = dg.CountryRegionCode
           AND hmd.PostalCode = dg.PostalCode
        LEFT JOIN ( 
            SELECT CustomerID, MIN(CAST(OrderDate AS DATE)) AS PurchaseDate
            FROM AdventureWorks.Sales.SalesOrderHeader
            GROUP BY CustomerID
        ) pd
            ON c.CustomerID = pd.CustomerID
    ) AS source
    ON target.CustomerAlternateKey = source.CustomerAlternateKey

    WHEN MATCHED THEN
        UPDATE SET 
            target.GeographyKey = source.GeographyKey,
            target.Title = source.Title,
            target.FirstName = source.FirstName,
            target.MiddleName = source.MiddleName,
            target.LastName = source.LastName,
            target.NameStyle = source.NameStyle,
            target.BirthDate = source.BirthDate,
            target.MaritalStatus = source.MaritalStatus,
            target.Suffix = source.Suffix,
            target.Gender = source.Gender,
            target.EmailAddress = source.EmailAddress,
            target.YearlyIncome = source.YearlyIncome,
            target.TotalChildren = source.TotalChildren,
            target.NumberChildrenAtHome = source.NumberChildrenAtHome,
            target.EnglishEducation = source.EnglishEducation,
            target.SpanishEducation = source.SpanishEducation,
            target.FrenchEducation = source.FrenchEducation,
            target.EnglishOccupation = source.EnglishOccupation,
            target.SpanishOccupation = source.SpanishOccupation,
            target.FrenchOccupation = source.FrenchOccupation,
            target.HouseOwnerFlag = source.HouseOwnerFlag,
            target.NumberCarsOwned = source.NumberCarsOwned,
            target.AddressLine1 = source.AddressLine1,
            target.AddressLine2 = source.AddressLine2,
            target.Phone = source.Phone,
            target.DateFirstPurchase = source.DateFirstPurchase,
            target.CommuteDistance = source.CommuteDistance

    WHEN NOT MATCHED THEN
        INSERT (
            GeographyKey, CustomerAlternateKey, Title, FirstName, MiddleName, LastName,
            NameStyle, BirthDate, MaritalStatus, Suffix, Gender, EmailAddress, YearlyIncome,
            TotalChildren, NumberChildrenAtHome,
            EnglishEducation, SpanishEducation, FrenchEducation,
            EnglishOccupation, SpanishOccupation, FrenchOccupation,
            HouseOwnerFlag, NumberCarsOwned, AddressLine1, AddressLine2, Phone,
            DateFirstPurchase, CommuteDistance
        )
        VALUES (
            source.GeographyKey, source.CustomerAlternateKey, source.Title, source.FirstName, source.MiddleName, source.LastName,
            source.NameStyle, source.BirthDate, source.MaritalStatus, source.Suffix, source.Gender, source.EmailAddress, source.YearlyIncome,
            source.TotalChildren, source.NumberChildrenAtHome,
            source.EnglishEducation, source.SpanishEducation, source.FrenchEducation,
            source.EnglishOccupation, source.SpanishOccupation, source.FrenchOccupation,
            source.HouseOwnerFlag, source.NumberCarsOwned, source.AddressLine1, source.AddressLine2, source.Phone,
            source.DateFirstPurchase, source.CommuteDistance
        );
END;