ALTER   PROCEDURE usp_LoadDimReseller
AS
BEGIN
    SET NOCOUNT ON;

    MERGE AdventureWorksDW.dbo.DimReseller AS target
    USING (
        SELECT
            s.BusinessEntityID,
            s.Name AS ResellerName,
            ISNULL(ph.PhoneNumber, 'Unknown') AS PhoneNumber,
            ISNULL(a.AddressLine1, 'Unknown') AS AddressLine1,
            ISNULL(a.AddressLine2, 'Unknown') AS AddressLine2,
            ISNULL(dg.GeographyKey, -1) AS GeographyKey
            -- SELECT COUNT(1)
        FROM AdventureWorks.Sales.Store s
        LEFT JOIN (
            SELECT 
                bea.BusinessEntityID,
                MIN(a.AddressID) AS AddressID
            FROM AdventureWorks.Person.BusinessEntityAddress bea
            INNER JOIN AdventureWorks.Person.Address a 
                ON bea.AddressID = a.AddressID
            GROUP BY bea.BusinessEntityID
        ) addrSel
            ON s.BusinessEntityID = addrSel.BusinessEntityID
        LEFT JOIN AdventureWorks.Person.Address a
            ON addrSel.AddressID = a.AddressID
        LEFT JOIN (
            SELECT 
                ph.BusinessEntityID,
                MIN(ph.PhoneNumber) AS PhoneNumber
            FROM AdventureWorks.Person.PersonPhone ph
            GROUP BY ph.BusinessEntityID
        ) ph
            ON s.BusinessEntityID = ph.BusinessEntityID
        LEFT JOIN AdventureWorks.Person.StateProvince sp
            ON a.StateProvinceID = sp.StateProvinceID
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
            ON dg.City = a.City
            AND dg.StateProvinceCode = sp.StateProvinceCode
            AND dg.CountryRegionCode = cr.CountryRegionCode
            AND dg.PostalCode = a.PostalCode
    ) AS source
    ON target.ResellerAlternateKey = source.BusinessEntityID

    WHEN MATCHED THEN
        UPDATE SET
            target.GeographyKey = source.GeographyKey,
            target.Phone = source.PhoneNumber,
            target.ResellerName = source.ResellerName,
            target.AddressLine1 = source.AddressLine1,
            target.AddressLine2 = source.AddressLine2

    WHEN NOT MATCHED THEN
        INSERT (
            GeographyKey,
            ResellerAlternateKey,
            Phone,
            BusinessType,
            ResellerName,
            NumberEmployees,
            OrderFrequency,
            OrderMonth,
            FirstOrderYear,
            LastOrderYear,
            ProductLine,
            AddressLine1,
            AddressLine2,
            AnnualSales,
            BankName,
            MinPaymentType,
            MinPaymentAmount,
            AnnualRevenue,
            YearOpened
        )
        VALUES (
            source.GeographyKey,
            source.BusinessEntityID,
            source.PhoneNumber,
            'Unknown',
            source.ResellerName,
            0,
            NULL,
            NULL,
            NULL,
            NULL,
            NULL,
            source.AddressLine1,
            source.AddressLine2,
            NULL,
            NULL,
            NULL,
            NULL,
            NULL,
            NULL
        );
END;