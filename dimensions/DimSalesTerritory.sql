ALTER PROCEDURE usp_LoadDimSalesTerritory
AS
BEGIN
    SET NOCOUNT ON;

    MERGE AdventureWorksDW.dbo.DimSalesTerritory AS target
    USING (
        SELECT DISTINCT 
            st.TerritoryID AS SalesTerritoryAlternateKey,
            st.Name AS SalesTerritoryRegion,
            st.CountryRegionCode AS SalesTerritoryCountry,
            st.[Group] AS SalesTerritoryGroup,
            CONVERT(VARBINARY(MAX), 'Unknown') AS SalesTerritoryImage
        FROM AdventureWorks.Sales.SalesTerritory st
    ) AS source
    ON target.SalesTerritoryAlternateKey = source.SalesTerritoryAlternateKey
    
    WHEN MATCHED THEN
        UPDATE SET
            target.SalesTerritoryRegion  = source.SalesTerritoryRegion,
            target.SalesTerritoryCountry = source.SalesTerritoryCountry,
            target.SalesTerritoryGroup   = source.SalesTerritoryGroup,
            target.SalesTerritoryImage   = source.SalesTerritoryImage
    
    WHEN NOT MATCHED THEN
        INSERT (
            SalesTerritoryAlternateKey,
            SalesTerritoryRegion,
            SalesTerritoryCountry,
            SalesTerritoryGroup,
            SalesTerritoryImage
        )
        VALUES (
            source.SalesTerritoryAlternateKey,
            source.SalesTerritoryRegion,
            source.SalesTerritoryCountry,
            source.SalesTerritoryGroup,
            source.SalesTerritoryImage
        );
END;