ALTER PROCEDURE usp_LoadDimAccount
AS
BEGIN
    SET NOCOUNT ON;

    MERGE AdventureWorksDW.dbo.DimAccount AS TARGET
    USING (
        VALUES
        (-1, -1, -1, 'Unknown Account', 'Unknown', 'Unknown', 'Unknown', 'Unknown', 'Unknown'),
        (1000, -1, -1, 'Assets', 'Balance Sheet', 'N/A', 'N/A', 'Currency', 'N/A'),
        (1100, 2, 1000, 'Cash', 'Balance Sheet', 'N/A', 'N/A', 'Currency', 'N/A'),
        (2000, -1, -1, 'Liabilities', 'Balance Sheet', 'N/A', 'N/A', 'Currency', 'N/A'),
        (4000, -1, -1, 'Revenue', 'Income Statement', 'N/A', 'N/A', 'Currency', 'N/A'),
        (5000, -1, -1, 'Expenses', 'Income Statement', 'N/A', 'N/A', 'Currency', 'N/A')
    ) AS SOURCE (
        AccountCodeAlternateKey,
        ParentAccountKey,
        ParentAccountCodeAlternateKey,
        AccountDescription,
        AccountType,
        Operator,
        CustomMembers,
        ValueType,
        CustomMemberOptions
    )
    ON TARGET.AccountCodeAlternateKey = SOURCE.AccountCodeAlternateKey
    WHEN MATCHED THEN
        UPDATE SET 
            TARGET.ParentAccountKey = SOURCE.ParentAccountKey,
            TARGET.ParentAccountCodeAlternateKey = SOURCE.ParentAccountCodeAlternateKey,
            TARGET.AccountDescription = SOURCE.AccountDescription,
            TARGET.AccountType = SOURCE.AccountType,
            TARGET.Operator = SOURCE.Operator,
            TARGET.CustomMembers = SOURCE.CustomMembers,
            TARGET.ValueType = SOURCE.ValueType,
            TARGET.CustomMemberOptions = SOURCE.CustomMemberOptions
    WHEN NOT MATCHED BY TARGET THEN
        INSERT (
            AccountCodeAlternateKey,
            ParentAccountKey,
            ParentAccountCodeAlternateKey,
            AccountDescription,
            AccountType,
            Operator,
            CustomMembers,
            ValueType,
            CustomMemberOptions
        )
        VALUES (
            SOURCE.AccountCodeAlternateKey,
            SOURCE.ParentAccountKey,
            SOURCE.ParentAccountCodeAlternateKey,
            SOURCE.AccountDescription,
            SOURCE.AccountType,
            SOURCE.Operator,
            SOURCE.CustomMembers,
            SOURCE.ValueType,
            SOURCE.CustomMemberOptions
        );
END;