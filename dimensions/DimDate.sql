ALTER PROCEDURE usp_LoadDimDate
AS
BEGIN
    SET NOCOUNT ON;

    -- Generate full date range
    ;WITH DateRange AS (
        SELECT CAST('2000-01-01' AS DATE) AS DateValue
        UNION ALL
        SELECT DATEADD(DAY, 1, DateValue)
        FROM DateRange
        WHERE DateValue < '2030-12-31'
    )
    SELECT *
    INTO #DateList
    FROM DateRange
    OPTION (MAXRECURSION 0);

    -- Insert/update real dates
    MERGE AdventureWorksDW.dbo.DimDate AS TARGET
    USING (
        SELECT 
            CONVERT(INT, CONVERT(CHAR(8), DateValue, 112)) AS DateKey,
            DateValue AS FullDateAlternateKey,
            DATEPART(WEEKDAY, DateValue) AS DayNumberOfWeek,
            DATENAME(WEEKDAY, DateValue) AS EnglishDayNameOfWeek,
            CASE DATENAME(WEEKDAY, DateValue)
                 WHEN 'Monday' THEN 'Lunes'
                 WHEN 'Tuesday' THEN 'Martes'
                 WHEN 'Wednesday' THEN N'Miércoles'
                 WHEN 'Thursday' THEN 'Jueves'
                 WHEN 'Friday' THEN 'Viernes'
                 WHEN 'Saturday' THEN N'Sábado'
                 WHEN 'Sunday' THEN 'Domingo'
            END AS SpanishDayNameOfWeek,
            CASE DATENAME(WEEKDAY, DateValue)
                 WHEN 'Monday' THEN 'Lundi'
                 WHEN 'Tuesday' THEN 'Mardi'
                 WHEN 'Wednesday' THEN 'Mercredi'
                 WHEN 'Thursday' THEN 'Jeudi'
                 WHEN 'Friday' THEN 'Vendredi'
                 WHEN 'Saturday' THEN 'Samedi'
                 WHEN 'Sunday' THEN 'Dimanche'
            END AS FrenchDayNameOfWeek,
            DAY(DateValue) AS DayNumberOfMonth,
            DATEPART(DAYOFYEAR, DateValue) AS DayNumberOfYear,
            DATEPART(WEEK, DateValue) AS WeekNumberOfYear,
            DATENAME(MONTH, DateValue) AS EnglishMonthName,
            CASE DATENAME(MONTH, DateValue)
                 WHEN 'January' THEN 'Enero'
                 WHEN 'February' THEN 'Febrero'
                 WHEN 'March' THEN 'Marzo'
                 WHEN 'April' THEN 'Abril'
                 WHEN 'May' THEN 'Mayo'
                 WHEN 'June' THEN 'Junio'
                 WHEN 'July' THEN 'Julio'
                 WHEN 'August' THEN 'Agosto'
                 WHEN 'September' THEN 'Septiembre'
                 WHEN 'October' THEN 'Octubre'
                 WHEN 'November' THEN 'Noviembre'
                 WHEN 'December' THEN 'Diciembre'
            END AS SpanishMonthName,
            CASE DATENAME(MONTH, DateValue)
                 WHEN 'January' THEN 'Janvier'
                 WHEN 'February' THEN N'Février'
                 WHEN 'March' THEN 'Mars'
                 WHEN 'April' THEN 'Avril'
                 WHEN 'May' THEN 'Mai'
                 WHEN 'June' THEN 'Juin'
                 WHEN 'July' THEN 'Juillet'
                 WHEN 'August' THEN N'Août'
                 WHEN 'September' THEN 'Septembre'
                 WHEN 'October' THEN 'Octobre'
                 WHEN 'November' THEN 'Novembre'
                 WHEN 'December' THEN 'Décembre'
            END AS FrenchMonthName,
            MONTH(DateValue) AS MonthNumberOfYear,
            DATEPART(QUARTER, DateValue) AS CalendarQuarter,
            YEAR(DateValue) AS CalendarYear,
            CASE WHEN DATEPART(QUARTER, DateValue) IN (1,2) THEN 1 ELSE 2 END AS CalendarSemester,
            DATEPART(QUARTER, DateValue) AS FiscalQuarter,
            YEAR(DateValue) AS FiscalYear,
            CASE WHEN DATEPART(QUARTER, DateValue) IN (1,2) THEN 1 ELSE 2 END AS FiscalSemester
        FROM #DateList
    ) AS SOURCE
    ON TARGET.DateKey = SOURCE.DateKey
    WHEN MATCHED THEN
        UPDATE SET
            TARGET.FullDateAlternateKey = SOURCE.FullDateAlternateKey,
            TARGET.DayNumberOfWeek = SOURCE.DayNumberOfWeek,
            TARGET.EnglishDayNameOfWeek = SOURCE.EnglishDayNameOfWeek,
            TARGET.SpanishDayNameOfWeek = SOURCE.SpanishDayNameOfWeek,
            TARGET.FrenchDayNameOfWeek = SOURCE.FrenchDayNameOfWeek,
            TARGET.DayNumberOfMonth = SOURCE.DayNumberOfMonth,
            TARGET.DayNumberOfYear = SOURCE.DayNumberOfYear,
            TARGET.WeekNumberOfYear = SOURCE.WeekNumberOfYear,
            TARGET.EnglishMonthName = SOURCE.EnglishMonthName,
            TARGET.SpanishMonthName = SOURCE.SpanishMonthName,
            TARGET.FrenchMonthName = SOURCE.FrenchMonthName,
            TARGET.MonthNumberOfYear = SOURCE.MonthNumberOfYear,
            TARGET.CalendarQuarter = SOURCE.CalendarQuarter,
            TARGET.CalendarYear = SOURCE.CalendarYear,
            TARGET.CalendarSemester = SOURCE.CalendarSemester,
            TARGET.FiscalQuarter = SOURCE.FiscalQuarter,
            TARGET.FiscalYear = SOURCE.FiscalYear,
            TARGET.FiscalSemester = SOURCE.FiscalSemester
    WHEN NOT MATCHED BY TARGET THEN
        INSERT (DateKey, FullDateAlternateKey, DayNumberOfWeek,
                EnglishDayNameOfWeek, SpanishDayNameOfWeek, FrenchDayNameOfWeek,
                DayNumberOfMonth, DayNumberOfYear, WeekNumberOfYear,
                EnglishMonthName, SpanishMonthName, FrenchMonthName,
                MonthNumberOfYear, CalendarQuarter, CalendarYear, CalendarSemester,
                FiscalQuarter, FiscalYear, FiscalSemester)
        VALUES (SOURCE.DateKey, SOURCE.FullDateAlternateKey, SOURCE.DayNumberOfWeek,
                SOURCE.EnglishDayNameOfWeek, SOURCE.SpanishDayNameOfWeek, SOURCE.FrenchDayNameOfWeek,
                SOURCE.DayNumberOfMonth, SOURCE.DayNumberOfYear, SOURCE.WeekNumberOfYear,
                SOURCE.EnglishMonthName, SOURCE.SpanishMonthName, SOURCE.FrenchMonthName,
                SOURCE.MonthNumberOfYear, SOURCE.CalendarQuarter, SOURCE.CalendarYear, SOURCE.CalendarSemester,
                SOURCE.FiscalQuarter, SOURCE.FiscalYear, SOURCE.FiscalSemester);

END;