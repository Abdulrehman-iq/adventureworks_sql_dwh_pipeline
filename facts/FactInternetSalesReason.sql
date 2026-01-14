ALTER PROCEDURE usp_LoadFactInternetSalesReason
AS
BEGIN
    SET NOCOUNT ON;

    MERGE AdventureWorksDW.dbo.FactInternetSalesReason AS target
    USING (
        SELECT
            soh.SalesOrderNumber,
            1 AS SalesOrderLineNumber,
            ISNULL(dsr.SalesReasonKey, -1) AS SalesReasonKey
            -- select count(1)
        FROM AdventureWorks.Sales.SalesOrderHeaderSalesReason AS sohsr
        JOIN AdventureWorks.Sales.SalesOrderHeader AS soh
            ON sohsr.SalesOrderID = soh.SalesOrderID
        LEFT JOIN AdventureWorks.Sales.SalesReason AS sr
            ON sohsr.SalesReasonID = sr.SalesReasonID
        LEFT JOIN AdventureWorksDW.dbo.DimSalesReason AS dsr
            ON dsr.SalesReasonAlternateKey = sr.SalesReasonID
    ) AS source
    ON target.SalesOrderNumber = source.SalesOrderNumber
       AND target.SalesReasonKey = source.SalesReasonKey
    WHEN NOT MATCHED BY TARGET THEN
        INSERT (
            SalesOrderNumber,
            SalesOrderLineNumber,
            SalesReasonKey
        )
        VALUES (
            source.SalesOrderNumber,
            source.SalesOrderLineNumber,
            source.SalesReasonKey
        );
END;