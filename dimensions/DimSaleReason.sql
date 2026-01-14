ALTER PROCEDURE usp_LoadDimSaleReason
AS
BEGIN
    SET NOCOUNT ON;

    MERGE AdventureWorksDW.dbo.DimSalesReason AS target
    USING (
        SELECT 
            sr.SalesReasonID AS SalesReasonAlternateKey,
            sr.Name AS SalesReasonName,
            sr.ReasonType AS SalesReasonReasonType
        FROM AdventureWorks.Sales.SalesReason sr
    ) AS source
    ON target.SalesReasonAlternateKey = source.SalesReasonAlternateKey
    WHEN MATCHED THEN
        UPDATE SET 
            target.SalesReasonName = source.SalesReasonName,
            target.SalesReasonReasonType = source.SalesReasonReasonType
    WHEN NOT MATCHED THEN
        INSERT (
            SalesReasonAlternateKey,
            SalesReasonName,
            SalesReasonReasonType
        )
        VALUES (
            source.SalesReasonAlternateKey,
            source.SalesReasonName,
            source.SalesReasonReasonType
        );
END;