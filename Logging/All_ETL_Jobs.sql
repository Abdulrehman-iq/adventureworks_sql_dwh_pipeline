ALTER   PROCEDURE usp_Master_ETL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE 
        @ProcessID INT,
        @ErrorMessage NVARCHAR(500),
        @JobName NVARCHAR(100),
    	@Stage VarChar(20);

    SELECT @ProcessID = ProcessID
    FROM dbo.ETL_Metadata
    WHERE ProcessName = OBJECT_NAME(@@PROCID);

    EXEC dbo.usp_ETL_Log @ProcessID = @ProcessID, @Stage = 'START';

    BEGIN TRY
        SET @JobName = 'usp_LoadDimOrganization';
        IF NOT EXISTS (
            SELECT 1 FROM dbo.ETL_Log 
            WHERE ProcessID = @ProcessID AND @Stage = @JobName AND Status = 'Success'
        )
        BEGIN
            EXEC usp_LoadDimOrganization;
            EXEC dbo.usp_ETL_Log @ProcessID = @ProcessID, @Stage = @JobName, @Status = 'Success';
        END

        SET @JobName = 'usp_LoadDimSalesReason';
        IF NOT EXISTS (
            SELECT 1 FROM dbo.ETL_Log 
            WHERE ProcessID = @ProcessID AND @Stage = @JobName AND Status = 'Success'
        )
        BEGIN
            EXEC usp_LoadDimSalesReason;
            EXEC dbo.usp_ETL_Log @ProcessID = @ProcessID, @Stage = @JobName, @Status = 'Success';
        END

        SET @JobName = 'usp_LoadDimGeography';
        IF NOT EXISTS (
            SELECT 1 FROM dbo.ETL_Log 
            WHERE ProcessID = @ProcessID AND @Stage = @JobName AND Status = 'Success'
        )
        BEGIN
            EXEC usp_LoadDimGeography;
            EXEC dbo.usp_ETL_Log @ProcessID = @ProcessID, @Stage = @JobName, @Status = 'Success';
        END

        SET @JobName = 'usp_LoadDimSalesTerritory';
        IF NOT EXISTS (
            SELECT 1 FROM dbo.ETL_Log 
            WHERE ProcessID = @ProcessID AND @Stage = @JobName AND Status = 'Success'
        )
        BEGIN
            EXEC usp_LoadDimSalesTerritory;
            EXEC dbo.usp_ETL_Log @ProcessID = @ProcessID, @Stage = @JobName, @Status = 'Success';
        END

        SET @JobName = 'usp_TestDimSalesReason_Error';
        IF NOT EXISTS (
            SELECT 1 FROM dbo.ETL_Log 
            WHERE ProcessID = @ProcessID AND @Stage = @JobName AND Status = 'Success'
        )
        BEGIN
            EXEC usp_TestDimSalesReason_Error;
            EXEC dbo.usp_ETL_Log @ProcessID = @ProcessID, @Stage = @JobName, @Status = 'Success';
        END

        SET @JobName = 'usp_TestDimGeographyError';
        IF NOT EXISTS (
            SELECT 1 FROM dbo.ETL_Log 
            WHERE ProcessID = @ProcessID AND @Stage = @JobName AND Status = 'Success'
        )
        BEGIN
            EXEC usp_TestDimGeographyError;
            EXEC dbo.usp_ETL_Log @ProcessID = @ProcessID, @Stage = @JobName, @Status = 'Success';
        END

        SET @JobName = 'usp_LoadCustomerBatch';
        IF NOT EXISTS (
            SELECT 1 FROM dbo.ETL_Log 
            WHERE ProcessID = @ProcessID AND @Stage = @JobName AND Status = 'Success'
        )
        BEGIN
            EXEC usp_LoadCustomerBatch;
            EXEC dbo.usp_ETL_Log @ProcessID = @ProcessID, @Stage = @JobName, @Status = 'Success';
        END

        EXEC dbo.usp_ETL_Log @ProcessID = @ProcessID, @Stage = 'END';
    END TRY

    BEGIN CATCH
        SET @ErrorMessage = ERROR_MESSAGE();
        EXEC dbo.usp_ETL_Log @ProcessID = @ProcessID, @Stage = @JobName, @Status = 'Failed', @ErrorMessage = @ErrorMessage;
        EXEC dbo.usp_ETL_Log @ProcessID = @ProcessID, @Stage = 'ERROR', @ErrorMessage = @ErrorMessage;
        RETURN;
    END CATCH
END;