--1. Find a Table by Name

SELECT * 
FROM sys.tables 
WHERE name LIKE '%TableName%'

--2. Find a View by Name

SELECT * 
FROM sys.views 
WHERE name LIKE '%ViewName%'

--3. Find a Function by Name

SELECT * 
FROM sys.objects 
WHERE type = 'FN' AND name LIKE '%FunctionName%'

--4. Find a Stored Procedure by Name

SELECT * 
FROM sys.procedures 
WHERE name LIKE '%ProcedureName%'

--5. Find Any Object by Name (Table, View, Procedure, Function)

SELECT * 
FROM sys.objects 
WHERE name LIKE '%ObjectName%'

--6. Search for a String in All Columns of a Specific Table

SELECT * 
FROM TableName 
WHERE Column1 LIKE '%SearchString%' 
   OR Column2 LIKE '%SearchString%' 
   -- Add more columns as needed

--7. Search for a String in All Tables of a Database
--This query dynamically searches across all the varchar and nvarchar columns:

DECLARE @SearchString NVARCHAR(100) = 'SearchString'

DECLARE @sql NVARCHAR(MAX) = ''

SELECT @sql = @sql + 'SELECT ''' + t.name + '.' + c.name + ''' AS ColumnName, ' + 
               't.name, c.name, ' + 
               'CAST(' + c.name + ' AS NVARCHAR(MAX)) AS Value ' + 
               'FROM ' + t.name + 
               ' WHERE ' + c.name + ' LIKE ''%' + @SearchString + '%'' UNION ALL ' 
FROM sys.columns c
JOIN sys.tables t ON c.object_id = t.object_id
JOIN sys.types ty ON c.user_type_id = ty.user_type_id
WHERE ty.name IN ('varchar', 'nvarchar')

SET @sql = LEFT(@sql, LEN(@sql) - 10) -- Remove the last UNION ALL
EXEC sp_executesql @sql

--8. Search for a String in All Stored Procedures

SELECT OBJECT_NAME(object_id), definition
FROM sys.sql_modules
WHERE definition LIKE '%SearchString%'

--9. Search for a String Across All Databases
--You can run the following query across multiple databases by using dynamic SQL. This is an example that loops through all databases:

DECLARE @SearchString NVARCHAR(100) = 'SearchString'
DECLARE @sql NVARCHAR(MAX) = ''

SELECT @sql = @sql + 'USE [' + name + ']; ' + 
              'SELECT ''' + name + ''' AS DatabaseName, ' + 
              'OBJECT_NAME(object_id) AS ObjectName, definition ' + 
              'FROM sys.sql_modules ' + 
              'WHERE definition LIKE ''%' + @SearchString + '%'' UNION ALL '
FROM sys.databases

SET @sql = LEFT(@sql, LEN(@sql) - 10) -- Remove the last UNION ALL
EXEC sp_executesql @sql
