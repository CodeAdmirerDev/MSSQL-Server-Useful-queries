--Creating an SQL script file to improve performance in an MS SQL Server environment involves a variety of best practices, configurations, and queries to monitor and optimize performance. 
--These can include monitoring CPU, memory, and IO usage, as well as tuning indexes, reviewing query plans, and collecting useful metrics.
--This file is an example .sql script that covers several performance-related areas. You can save this as a .sql file and run it in SQL Server Management Studio (SSMS).

-- Performance Optimization and Monitoring Script for SQL Server

-- Part 1: General System Information
SELECT 
    SERVERPROPERTY('ProductVersion') AS SQLServerVersion,
    SERVERPROPERTY('Edition') AS Edition,
    SERVERPROPERTY('EngineEdition') AS EngineEdition,
    SERVERPROPERTY('ProductLevel') AS ProductLevel,
    SERVERPROPERTY('MachineName') AS MachineName;

-- Part 2: Check CPU and Memory Usage
SELECT 
    sqlserver_start_time,
    cpu_count,
    physical_memory_in_use_kb / 1024 AS memory_in_use_MB,
    available_memory_kb / 1024 AS available_memory_MB
FROM sys.dm_os_sys_info;

-- Part 3: Identify Long Running Queries
SELECT 
    sql_handle,
    plan_handle,
    total_elapsed_time / 1000000 AS elapsed_time_sec,
    total_worker_time / 1000000 AS cpu_time_sec,
    total_logical_reads AS logical_reads,
    total_logical_writes AS logical_writes,
    execution_count
FROM sys.dm_exec_query_stats
ORDER BY total_elapsed_time DESC;

-- Part 4: Missing Indexes
SELECT 
    CONVERT(decimal(18,2), migs.avg_total_user_cost * migs.avg_user_impact * (migs.user_seeks + migs.user_scans)) AS improvement_measure,
    mid.statement AS table_name,
    mid.equality_columns,
    mid.inequality_columns,
    mid.included_columns
FROM sys.dm_db_missing_index_groups mig
JOIN sys.dm_db_missing_index_group_stats migs ON migs.group_handle = mig.index_group_handle
JOIN sys.dm_db_missing_index_details mid ON mig.index_handle = mid.index_handle
ORDER BY improvement_measure DESC;

-- Part 5: Index Fragmentation
SELECT 
    DB_NAME(ps.database_id) AS database_name,
    OBJECT_NAME(ps.object_id) AS table_name,
    i.name AS index_name,
    ps.avg_fragmentation_in_percent,
    ps.page_count
FROM sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, 'LIMITED') AS ps
JOIN sys.indexes AS i ON ps.object_id = i.object_id AND ps.index_id = i.index_id
WHERE ps.avg_fragmentation_in_percent > 10 AND ps.page_count > 1000
ORDER BY ps.avg_fragmentation_in_percent DESC;

-- Part 6: Monitor Disk I/O
SELECT 
    vfs.database_id,
    DB_NAME(vfs.database_id) AS database_name,
    vfs.file_id,
    mf.physical_name,
    vfs.num_of_reads,
    vfs.num_of_writes,
    vfs.io_stall_read_ms,
    vfs.io_stall_write_ms
FROM sys.dm_io_virtual_file_stats(NULL, NULL) AS vfs
JOIN sys.master_files AS mf ON vfs.database_id = mf.database_id AND vfs.file_id = mf.file_id
ORDER BY vfs.io_stall_read_ms DESC;

-- Part 7: Query Execution Plans with High Costs
SELECT 
    TOP 10 query_plan_hash,
    creation_time,
    execution_count,
    total_worker_time / 1000 AS total_cpu_time_ms,
    total_elapsed_time / 1000 AS total_elapsed_time_ms,
    query_hash,
    query_plan
FROM sys.dm_exec_query_stats qs
CROSS APPLY sys.dm_exec_query_plan(qs.plan_handle)
ORDER BY total_worker_time DESC;

-- Part 8: Cache Usage and Efficiency
SELECT 
    objtype AS CacheType,
    COUNT(*) AS CachedPlans,
    SUM(CAST(size_in_bytes AS BIGINT)) / 1024 / 1024 AS CacheSizeMB
FROM sys.dm_exec_cached_plans
GROUP BY objtype
ORDER BY CacheSizeMB DESC;

-- Part 9: Index Usage Statistics
SELECT 
    OBJECT_NAME(s.object_id) AS table_name,
    i.name AS index_name,
    s.user_seeks,
    s.user_scans,
    s.user_lookups,
    s.user_updates
FROM sys.dm_db_index_usage_stats AS s
JOIN sys.indexes AS i ON i.object_id = s.object_id AND i.index_id = s.index_id
WHERE OBJECTPROPERTY(s.object_id,'IsUserTable') = 1
ORDER BY s.user_scans DESC;

-- Part 10: Check for Blocking and Wait Statistics
SELECT 
    session_id,
    blocking_session_id,
    wait_type,
    wait_time,
    wait_resource,
    transaction_id,
    cpu_time,
    logical_reads,
    reads,
    writes
FROM sys.dm_exec_requests
WHERE blocking_session_id <> 0;

-- Part 11: TempDB Contention
SELECT 
    SUM(wait_time_ms) AS total_wait_time_ms,
    session_id,
    wait_type,
    resource_description
FROM sys.dm_os_waiting_tasks
WHERE wait_type LIKE 'PAGEIOLATCH_%'
AND resource_description LIKE '2:%' -- TempDB resource ID is 2
GROUP BY session_id, wait_type, resource_description;

-- Part 12: DBCC CHECKDB for Integrity
DBCC CHECKDB (YOUR_DATABASE_NAME) WITH NO_INFOMSGS, ALL_ERRORMSGS;

-- Part 13: Update Statistics
-- Update all statistics in the current database to improve query performance.
EXEC sp_updatestats;

-- Part 14: Rebuild Fragmented Indexes (Conditional)
-- Rebuild indexes for a specific database if fragmentation is above 30%.
DECLARE @TableName VARCHAR(255);
DECLARE @sql NVARCHAR(MAX);

DECLARE index_cursor CURSOR FOR
SELECT OBJECT_NAME(ps.object_id)
FROM sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, 'LIMITED') AS ps
WHERE avg_fragmentation_in_percent > 30;

OPEN index_cursor;

FETCH NEXT FROM index_cursor INTO @TableName;

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @sql = 'ALTER INDEX ALL ON [' + @TableName + '] REBUILD;';
    EXEC sp_executesql @sql;
    FETCH NEXT FROM index_cursor INTO @TableName;
END;

CLOSE index_cursor;
DEALLOCATE index_cursor;

-- End of Performance Optimization Script

---- Key Elements in the Script: ----
/*
System Info: Basic system properties (e.g., SQL Server version, edition).
CPU and Memory: Retrieves current CPU and memory usage.
Long-Running Queries: Identifies queries with the longest execution times.
Missing Indexes: Detects missing indexes that could improve performance.
Index Fragmentation: Shows indexes with fragmentation for potential rebuilding.
Disk I/O: Monitors disk I/O statistics to spot bottlenecks.
Query Plans: Identifies expensive query plans for optimization.
Cache Efficiency: Monitors the cache for inefficiency.
Index Usage: Provides statistics on index usage, useful for tuning.
Blocking & Waits: Finds sessions being blocked and major wait types.
TempDB Contention: Identifies contention in TempDB, a common bottleneck.
Integrity Check: Runs DBCC CHECKDB for database integrity verification.
Update Statistics: Updates statistics to improve query performance.
Rebuild Indexes: Rebuilds fragmented indexes to boost performance.

You can save this script as Performance_Optimization.sql and use it to monitor and optimize performance in SQL Server. 
Modify the database names and thresholds (e.g., for index fragmentation) as per your needs.
*/
