ALTER   PROCEDURE usp_LoadDimGeography
AS
BEGIN
    SET NOCOUNT ON;

    MERGE AdventureWorksDW.dbo.DimGeography AS TARGET
    USING (
        SELECT 
            a.City,
            sp.StateProvinceCode,
            sp.Name AS StateProvinceName,
            cr.CountryRegionCode,
            cr.Name AS EnglishCountryRegionName,
            'Unknown' AS SpanishCountryRegionName,
            'Unknown' AS FrenchCountryRegionName,
            a.PostalCode,
            ISNULL(dst.SalesTerritoryKey, -1) AS SalesTerritoryKey,
            -1 AS IpAddressLocator
        FROM AdventureWorks.Person.Address a
        JOIN AdventureWorks.Person.StateProvince sp 
            ON a.StateProvinceID = sp.StateProvinceID
        JOIN AdventureWorks.Person.CountryRegion cr 
            ON sp.CountryRegionCode = cr.CountryRegionCode
        LEFT JOIN AdventureWorksDW.dbo.DimSalesTerritory dst
            ON sp.TerritoryID  = dst.SalesTerritoryAlternateKey
    ) AS SOURCE
        ON TARGET.City = SOURCE.City
       AND TARGET.StateProvinceCode = SOURCE.StateProvinceCode
       AND TARGET.PostalCode = SOURCE.PostalCode

    WHEN NOT MATCHED BY TARGET THEN
        INSERT (
            City,
            StateProvinceCode,
            StateProvinceName,
            CountryRegionCode,
            EnglishCountryRegionName,
            SpanishCountryRegionName,
            FrenchCountryRegionName,
            PostalCode,
            SalesTerritoryKey,
            IpAddressLocator
        )
        VALUES (
            SOURCE.City,
            SOURCE.StateProvinceCode,
            SOURCE.StateProvinceName,
            SOURCE.CountryRegionCode,
            SOURCE.EnglishCountryRegionName,
            SOURCE.SpanishCountryRegionName,
            SOURCE.FrenchCountryRegionName,
            SOURCE.PostalCode,
            SOURCE.SalesTerritoryKey,
            SOURCE.IpAddressLocator
        );
END