ALTER PROCEDURE usp_LoadFactProductInventory
AS
BEGIN
    SET NOCOUNT ON;

    MERGE AdventureWorksDW.dbo.FactProductInventory AS target
    USING (
        SELECT
            dp.ProductKey,
            dd.DateKey,
            CAST(pi.ModifiedDate AS DATE) AS MovementDate,
            AVG(p.StandardCost) AS UnitCost,
            SUM(pi.Quantity) AS UnitsIn,
            0 AS UnitsOut,
            SUM(pi.Quantity) AS UnitsBalance
            -- select count(1)
        FROM AdventureWorks.Production.ProductInventory AS pi
        INNER JOIN AdventureWorks.Production.Product AS p
            ON pi.ProductID = p.ProductID
        INNER JOIN AdventureWorksDW.dbo.DimProduct AS dp
            ON dp.ProductAlternateKey = p.ProductNumber
        INNER JOIN AdventureWorksDW.dbo.DimDate AS dd
            ON dd.FullDateAlternateKey = CAST(pi.ModifiedDate AS DATE)
        GROUP BY
            dp.ProductKey,
            dd.DateKey,
            CAST(pi.ModifiedDate AS DATE)
    ) AS source
    ON target.ProductKey = source.ProductKey
       AND target.DateKey = source.DateKey
       AND target.MovementDate = source.MovementDate
    WHEN NOT MATCHED BY TARGET THEN
        INSERT (
            ProductKey,
            DateKey,
            MovementDate,
            UnitCost,
            UnitsIn,
            UnitsOut,
            UnitsBalance
        )
        VALUES (
            source.ProductKey,
            source.DateKey,
            source.MovementDate,
            source.UnitCost,
            source.UnitsIn,
            source.UnitsOut,
            source.UnitsBalance
        );
END;