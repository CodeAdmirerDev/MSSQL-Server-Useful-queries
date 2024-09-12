--Most useful queries in MS SQL server
--Here’s a collection of some of the most useful and common queries in Microsoft SQL Server, covering essential tasks such as data retrieval, database management, and performance optimization:

--1. Basic SELECT Query
  
SELECT column1, column2 
FROM TableName
WHERE condition

--2. Selecting Top N Rows
 
SELECT TOP 10 * 
FROM TableName

--3. Filtering with WHERE
 
SELECT * 
FROM TableName 
WHERE ColumnName = 'Value'

--4. Sorting with ORDER BY
 
SELECT * 
FROM TableName 
ORDER BY ColumnName ASC

--5. Aggregate Functions (SUM, COUNT, AVG, MIN, MAX)
 
SELECT SUM(ColumnName), COUNT(*), AVG(ColumnName), MIN(ColumnName), MAX(ColumnName)
FROM TableName

--6. GROUP BY with HAVING
  
SELECT ColumnName, COUNT(*)
FROM TableName
GROUP BY ColumnName
HAVING COUNT(*) > 1

--7. Joining Tables (INNER JOIN)
  
SELECT a.Column1, b.Column2
FROM TableA a
INNER JOIN TableB b ON a.CommonColumn = b.CommonColumn

--8. LEFT JOIN (Outer Join)
 
SELECT a.Column1, b.Column2
FROM TableA a
LEFT JOIN TableB b ON a.CommonColumn = b.CommonColumn

--9. Subqueries
 
SELECT Column1
FROM TableA
WHERE Column2 IN (SELECT Column2 FROM TableB WHERE condition)

--10. Common Table Expressions (CTE)
 
WITH CTE AS (
    SELECT Column1, Column2
    FROM TableName
    WHERE condition
)
SELECT * 
FROM CTE

--11. Inserting Data 
 
INSERT INTO TableName (Column1, Column2)
VALUES ('Value1', 'Value2')

--12. Updating Data
  
UPDATE TableName
SET Column1 = 'NewValue'
WHERE condition

--13. Deleting Data
 
DELETE FROM TableName
WHERE condition

--14. String Functions

--Concatenation:
SELECT CONCAT(Column1, ' ', Column2) AS FullName 
FROM TableName

--Substring:
SELECT SUBSTRING(ColumnName, 1, 5)
FROM TableName

--Length of a string:
SELECT LEN(ColumnName)
FROM TableName
  
--15. Date Functions

--Current Date/Time:
SELECT GETDATE() 

--Extract Year, Month, Day:
SELECT YEAR(ColumnName), MONTH(ColumnName), DAY(ColumnName)
FROM TableName
  
--Date Difference:
SELECT DATEDIFF(day, StartDateColumn, EndDateColumn)
FROM TableName
  
--16. CASE (Conditional Logic)
 
SELECT Column1,
       CASE 
           WHEN Condition1 THEN 'Result1'
           WHEN Condition2 THEN 'Result2'
           ELSE 'Result3'
       END AS NewColumn
FROM TableName

--17. Using EXISTS
 
SELECT Column1
FROM TableA
WHERE EXISTS (SELECT 1 FROM TableB WHERE TableA.CommonColumn = TableB.CommonColumn)

--18. Creating Indexes
  
--Create an Index:
CREATE INDEX IX_IndexName
ON TableName (ColumnName)

--Drop an Index:
DROP INDEX IX_IndexName ON TableName
  
--19. Execution Plans and Performance Tuning

--Show Execution Plan:
 
SET SHOWPLAN_ALL ON
GO
SELECT * FROM TableName
GO
SET SHOWPLAN_ALL OFF

--Check Query Execution Time:

SET STATISTICS TIME ON
SELECT * FROM TableName
SET STATISTICS TIME OFF

--20. Transaction Handling

--Begin Transaction:
BEGIN TRANSACTION

--Commit Transaction: 
COMMIT TRANSACTION
  
--Rollback Transaction:
ROLLBACK TRANSACTION
  
--21. Check Active Connections and Sessions
SELECT session_id, login_name, status
FROM sys.dm_exec_sessions
  
--22. Get Database Size
EXEC sp_spaceused

--23. Show Current User and Database
SELECT USER_NAME(), DB_NAME()

--24. View Locks and Blocking Transactions 
SELECT * 
FROM sys.dm_tran_locks
  
--25. Check SQL Server Version 
SELECT @@VERSION
