/*
Stored procedures in SQL Server Management Studio (SSMS) allow you to encapsulate a set of SQL statements that can be executed multiple times with a single call. 
They can accept parameters, return data, and manage transactions, making them powerful for encapsulating complex business logic. 
Here's a detailed guide on creating and optimizing stored procedures in SSMS, along with best practices and coding standards.
*/

--1. Creating a Stored Procedure
--Stored procedures in SQL Server are created using the CREATE PROCEDURE statement. Below is a basic syntax for creating a stored procedure:

CREATE PROCEDURE [schema_name].[procedure_name]
    @Parameter1 DataType,
    @Parameter2 DataType OUTPUT -- OUTPUT is optional for returning values
AS
BEGIN
    -- SQL statements
END

--Example:

CREATE PROCEDURE dbo.GetEmployeeDetails
    @EmployeeID INT
AS
BEGIN
    SELECT FirstName, LastName, Department
    FROM Employees
    WHERE EmployeeID = @EmployeeID;
END

--2. Executing a Stored Procedure
--Once created, you can execute a stored procedure using the EXEC or EXECUTE command:

  EXEC dbo.GetEmployeeDetails @EmployeeID = 1;

--You can also use parameters to pass values, and if there are OUTPUT parameters, capture the results.

--3. Stored Procedure with Parameters
--Stored procedures can have input parameters (mandatory/optional) and output parameters:

--Input Parameters:

CREATE PROCEDURE dbo.GetProductInfo
    @ProductID INT = NULL  -- Optional Parameter
AS
BEGIN
    IF @ProductID IS NOT NULL
    BEGIN
        SELECT * FROM Products WHERE ProductID = @ProductID;
    END
    ELSE
    BEGIN
        SELECT * FROM Products;
    END
END

--Output Parameters:

CREATE PROCEDURE dbo.GetTotalEmployees
    @TotalCount INT OUTPUT
AS
BEGIN
    SELECT @TotalCount = COUNT(*) FROM Employees;
END

--To execute this:

DECLARE @Total INT;
EXEC dbo.GetTotalEmployees @TotalCount = @Total OUTPUT;
SELECT @Total;

--4. Error Handling
--Error handling within a stored procedure is crucial to ensure that your code can manage failures and rollback transactions when necessary.

--Use TRY...CATCH blocks for error handling:

CREATE PROCEDURE dbo.TransferFunds
    @SourceAccount INT,
    @TargetAccount INT,
    @Amount DECIMAL(10, 2)
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Withdraw from source account
        UPDATE Accounts SET Balance = Balance - @Amount WHERE AccountID = @SourceAccount;

        -- Deposit to target account
        UPDATE Accounts SET Balance = Balance + @Amount WHERE AccountID = @TargetAccount;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;

        -- Handle error
        SELECT ERROR_MESSAGE() AS ErrorMessage;
    END CATCH
END

--5. Optimization and Best Practices

--Here are some techniques to optimize stored procedures and ensure best performance:

--a) Avoid * in SELECT statement :

  -- Specify only the columns you need to reduce I/O and improve performance:
SELECT FirstName, LastName FROM Employees WHERE EmployeeID = @EmployeeID;

--b) Use SET NOCOUNT ON:

--To prevent sending unnecessary messages to the client, use SET NOCOUNT ON:

CREATE PROCEDURE dbo.MyProcedure
AS
BEGIN
    SET NOCOUNT ON;

    -- Procedure logic

    SET NOCOUNT OFF;
END

--c) Parameter Sniffing:
--Parameter sniffing occurs when SQL Server uses the first set of parameters passed to a procedure to create an execution plan, which can be reused. In cases where different parameter values have significantly different data distributions, this can cause suboptimal plans.

--To prevent issues:

Use OPTION (RECOMPILE) if the plan should not be reused.

--Reassign parameters to local variables to prevent sniffing:

CREATE PROCEDURE dbo.SearchOrders
    @OrderDate DATE
AS
BEGIN
    DECLARE @LocalOrderDate DATE = @OrderDate;

    SELECT * FROM Orders WHERE OrderDate = @LocalOrderDate;
END

--d) Avoid Cursors If Possible:
--Cursors can be slow due to row-by-row processing. Use set-based operations instead. If you must use a cursor, try FAST_FORWARD or READ_ONLY cursors to minimize resource usage:

DECLARE cursor_name CURSOR FAST_FORWARD FOR
SELECT EmployeeID FROM Employees;

OPEN cursor_name;
FETCH NEXT FROM cursor_name;
-- Process data
CLOSE cursor_name;
DEALLOCATE cursor_name;

--e) Indexing:
--Make sure to create proper indexes on columns used in WHERE clauses or joins. Always check the execution plan of your queries to identify potential missing indexes.

--f) Avoid Nested Stored Procedures:
--Avoid excessive nesting of stored procedures or recursive calls, as they can lead to performance degradation. Modularize code wisely.

--g) Use Transactions Wisely:
--Make sure transactions are as short as possible to avoid locking issues and deadlocks.

BEGIN TRANSACTION;
-- Critical section of the code
COMMIT TRANSACTION;

--h) Use SARGable Queries:
--Ensure your WHERE clause is SARGable (search argument capable). For example, avoid functions on columns in WHERE clauses, as they can prevent the use of indexes:

-- Avoid this:
WHERE YEAR(OrderDate) = 2023

-- Use this instead:
WHERE OrderDate >= '2023-01-01' AND OrderDate < '2024-01-01'

--i) Use Proper Data Types:
--Ensure that the data types of your parameters match the underlying column types to avoid implicit conversions, which can affect performance. Avoid unnecessary large data types like VARCHAR(MAX) when a smaller size is sufficient.

--j) Caching and Plan Reuse:
--By default, SQL Server caches execution plans. However, in some cases, plan reuse can cause problems. To force recompilation of a stored procedure each time it is executed, use:

WITH RECOMPILE;

--Example:
EXEC dbo.ProcedureName WITH RECOMPILE;

--k) Use Table-Valued Parameters (TVPs) for Batch Operations:
--If you need to pass multiple values into a stored procedure, use TVPs instead of repeatedly calling the procedure in a loop. This is more efficient and can avoid deadlocks or long transaction times.


--6. Coding Standards and Best Practices

/*

Naming Conventions:

Use descriptive and meaningful names for stored procedures (e.g., spGetCustomerOrders, uspUpdateEmployee).
Prefix system procedures with sp_ but avoid this for user-defined procedures as SQL Server first checks system procedures in the master database when using this prefix.
Consistent Formatting:

Align SQL keywords (e.g., SELECT, FROM, WHERE) and indent SQL code for readability.
Use capital letters for SQL keywords (e.g., SELECT, FROM, WHERE) and lowercase for table/column names.
Commenting:

Always include comments for complicated logic, business rules, and special handling.

-- Fetching employee details based on EmployeeID
Version Control:

Use version numbers in comments at the top of the stored procedure for tracking changes.

/*
    Procedure Name: dbo.GetEmployeeDetails
    Version: 1.0
    Author: CodeAdmirer
    Date: 2024-09-12
*/

*/

/*
Conclusion
Stored procedures in SQL Server provide a powerful way to encapsulate business logic, improve performance, and simplify database management. 
Following the above best practices and coding standards will help you create efficient and maintainable stored procedures, optimized for performance and scalability.

*/
