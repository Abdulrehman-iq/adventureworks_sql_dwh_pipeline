ALTER   PROCEDURE usp_LoadDimOrganization
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE 
        @ProcessID INT,
        @RowsInserted INT = 0,
        @ErrorMessage NVARCHAR(1000) = NULL;

    SELECT @ProcessID = ProcessID
    FROM dbo.ETL_Metadata
    WHERE ProcessName = OBJECT_NAME(@@PROCID);

    BEGIN TRY
        EXEC dbo.usp_ETL_Log @ProcessID = @ProcessID, @Stage = 'START';

        MERGE AdventureWorksDW.dbo.DimOrganization AS TARGET
        USING (
            SELECT 
                -1 AS ParentOrganizationKey,
                0 AS PercentageOfOwnership,
                d.GroupName AS OrganizationName,
                ISNULL(dc.CurrencyKey, -1) AS CurrencyKey
            FROM AdventureWorks.HumanResources.Department d
            LEFT JOIN AdventureWorks.Sales.Currency c
                ON c.CurrencyCode = 'USD'
            LEFT JOIN AdventureWorksDW.dbo.DimCurrency dc
                ON c.CurrencyCode = dc.CurrencyAlternateKey
        ) AS SOURCE
        ON TARGET.OrganizationName = SOURCE.OrganizationName
           AND TARGET.CurrencyKey = SOURCE.CurrencyKey
        WHEN NOT MATCHED BY TARGET THEN
            INSERT (
                ParentOrganizationKey,
                PercentageOfOwnership,
                OrganizationName,
                CurrencyKey
            )
            VALUES (
                SOURCE.ParentOrganizationKey,
                SOURCE.PercentageOfOwnership,
                SOURCE.OrganizationName,
                SOURCE.CurrencyKey
            );

        SET @RowsInserted = @@ROWCOUNT;

        EXEC dbo.usp_ETL_Log 
            @ProcessID = @ProcessID, 
            @Stage = 'END', 
            @RowsInserted = @RowsInserted;
    END TRY
    BEGIN CATCH
        SET @ErrorMessage = ERROR_MESSAGE();
        EXEC dbo.usp_ETL_Log 
            @ProcessID = @ProcessID, 
            @Stage = 'ERROR', 
            @ErrorMessage = @ErrorMessage;
    END CATCH;
END;