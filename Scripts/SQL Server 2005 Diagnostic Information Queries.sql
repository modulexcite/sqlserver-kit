
-- SQL Server 2005 Diagnostic Information Queries
-- Glenn Berry 
-- March 2015
-- Last Modified: March 31, 2015
-- http://sqlserverperformance.wordpress.com/
-- http://sqlskills.com/blogs/glenn/
-- Twitter: GlennAlanBerry

-- Please listen to my Pluralsight courses
-- http://www.pluralsight.com/author/glenn-berry

-- Many of these queries will not work if you have databases in 80 compatibility mode
-- Please make sure you are using the correct version of these diagnostic queries for your version of SQL Server

--******************************************************************************
--*   Copyright (C) 2015 Glenn Berry, SQLskills.com
--*   All rights reserved. 
--*
--*   For more scripts and sample code, check out 
--*      http://sqlskills.com/blogs/glenn
--*
--*   You may alter this code for your own *non-commercial* purposes. You may
--*   republish altered code as long as you include this copyright and give due credit. 
--*
--*
--*   THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF 
--*   ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED 
--*   TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
--*   PARTICULAR PURPOSE. 
--*
--******************************************************************************

-- Check the major product version to see if it is SQL Server 2005
IF NOT EXISTS (SELECT * WHERE CONVERT(varchar(128), SERVERPROPERTY('ProductVersion')) LIKE '9%')
	BEGIN
		DECLARE @ProductVersion varchar(128); 
		SET @ProductVersion = CONVERT(varchar(128), SERVERPROPERTY('ProductVersion'));
		RAISERROR ('Script does not match the ProductVersion [%s] of this instance. Many of these queries may not work on this version.' , 18 , 16 , @ProductVersion);
	END
	ELSE
		PRINT N'You have the correct major version of SQL Server for this diagnostic information script';


-- SQL Version information for current instance  (Query 1) (Version Info)
SELECT @@SERVERNAME AS [Server Name], @@VERSION AS [SQL Server and OS Version Info];

-- SQL Server 2005 is out of mainsteam support from Microsoft
-- Build 9.0.5266 was the last cumulative update


--   SQL 2005 SP2 Builds             SQL 2005 SP3 Builds            SQL 2005 SP4 Builds
-- Build          Description         Build         Description     Build		   Description
-- 9.0.3042        SP2 RTM			  9.0.4035        SP3 RTM
-- 9.0.3161        SP2 CU1			  9.0.4207        SP3 CU1
-- 9.0.3175        SP2 CU2			  9.0.4211        SP3 CU2 
-- 9.0.3186        SP2 CU3			  9.0.4220       SP3 CU3         
-- 9.0.3200        SP2 CU4			  9.0.4226        SP3 CU4         
-- 9.0.3215        SP2 CU5			  9.0.4230		  SP3 CU5          
-- 9.0.3228		   SP2 CU6			  9.0.4266        SP3 CU6        
-- 9.0.3239        SP2 CU7			  9.0.4273		  SP3 CU7        
-- 9.0.3257        SP2 CU8			  9.0.4285        SP3 CU8
-- 9.0.3282        SP2 CU9			  9.0.4294		  SP3 CU9
-- 9.0.3294		   SP2 CU10			  9.0.4305        SP3 CU10
-- 9.0.3301		   SP2 CU11			  9.0.4309		  SP3 CU11  ---> 9.0.5000		SP4 RTM
-- 9.0.3315        SP2 CU12           9.0.4311        SP3 CU12  ---> 9.0.5254       SP4 CU1		12/22/2010
-- 9.0.3325		   SP2 CU13			  9.0.4315		  SP3 CU13
-- 9.0.3328        SP2 CU14			  9.0.4317		  SP3 CU14	---> 9.0.5259		SP4 CU2		 2/21/2011
-- 9.0.3330        SP2 CU15			  9.0.4325		  SP3 CU15	---> 9.0.5266		SP4 CU3      3/21/2011
-- 9.0.3355        SP2 CU16
-- 9.0.3356		   SP2 CU17



-- The SQL Server 2005 builds that were released after SQL Server 2005 Service Pack 2 was released
-- http://support.microsoft.com/kb/937137

-- The SQL Server 2005 builds that were released after SQL Server 2005 Service Pack 3 was released
-- http://support.microsoft.com/kb/960598

-- The SQL Server 2005 builds that were released after SQL Server 2005 Service Pack 4 was released 
-- http://support.microsoft.com/kb/2485757

-- SQL Server 2005 fell out of Mainsteam Support on April 12, 2011
-- This means no more Service Packs or Cumulative Updates
-- SQL Server 2005 will end Extended Support on April 12, 2016 

-- SQL Server 2005 Service Pack 4
-- http://www.microsoft.com/en-us/download/details.aspx?id=7218



-- When was SQL Server installed  (Query 2) (SQL Server Install Date)  
SELECT @@SERVERNAME AS [Server Name], create_date AS [SQL Server Install Date] 
FROM sys.server_principals WITH (NOLOCK)
WHERE name = N'NT AUTHORITY\SYSTEM'
OR name = N'NT AUTHORITY\NETWORK SERVICE' OPTION (RECOMPILE);

-- Tells you the date and time that SQL Server was installed
-- It is a good idea to know how old your instance is


-- Get selected server properties (SQL Server 2005)  (Query 3) (Server Properties)
SELECT SERVERPROPERTY('MachineName') AS [MachineName], SERVERPROPERTY('ServerName') AS [ServerName],  
SERVERPROPERTY('InstanceName') AS [Instance], SERVERPROPERTY('IsClustered') AS [IsClustered], 
SERVERPROPERTY('ComputerNamePhysicalNetBIOS') AS [ComputerNamePhysicalNetBIOS], 
SERVERPROPERTY('Edition') AS [Edition], SERVERPROPERTY('ProductLevel') AS [ProductLevel], 
SERVERPROPERTY('ProductVersion') AS [ProductVersion], SERVERPROPERTY('ProcessID') AS [ProcessID],
SERVERPROPERTY('Collation') AS [Collation], SERVERPROPERTY('IsFullTextInstalled') AS [IsFullTextInstalled], 
SERVERPROPERTY('IsIntegratedSecurityOnly') AS [IsIntegratedSecurityOnly];

-- This gives you a lot of useful information about your instance of SQL Server,
-- such as the ProcessID for SQL Server and your collation


-- Get SQL Server Agent jobs and Category information (Query 4) (SQL Server Agent Jobs)
SELECT sj.name AS [JobName], sj.[description] AS [JobDescription], SUSER_SNAME(sj.owner_sid) AS [JobOwner],
sj.date_created, sj.[enabled], sj.notify_email_operator_id, sj.notify_level_email, sc.name AS [CategoryName],
js.next_run_date, js.next_run_time
FROM msdb.dbo.sysjobs AS sj WITH (NOLOCK)
INNER JOIN msdb.dbo.syscategories AS sc WITH (NOLOCK)
ON sj.category_id = sc.category_id
LEFT OUTER JOIN msdb.dbo.sysjobschedules AS js WITH (NOLOCK)
ON sj.job_id = js.job_id
ORDER BY sj.name OPTION (RECOMPILE);

-- Gives you some basic information about your SQL Server Agent jobs, who owns them and how they are configured
-- Look for Agent jobs that are not owned by sa
-- Look for jobs that have a notify_email_operator_id set to 0 (meaning no operator)
-- Look for jobs that have a notify_level_email set to 0 (meaning no e-mail is ever sent)
--
-- MSDN sysjobs documentation
-- http://msdn.microsoft.com/en-us/library/ms189817.aspx


-- Get SQL Server Agent Alert Information (Query 5) (SQL Server Agent Alerts)
SELECT name, event_source, message_id, severity, [enabled], has_notification, 
       delay_between_responses, occurrence_count, last_occurrence_date, last_occurrence_time
FROM msdb.dbo.sysalerts WITH (NOLOCK)
ORDER BY name OPTION (RECOMPILE);

-- Gives you some basic information about your SQL Server Agent Alerts (which are different from SQL Server Agent jobs)
-- Read more about Agent Alerts here: http://www.sqlskills.com/blogs/glenn/creating-sql-server-agent-alerts-for-critical-errors/


-- Returns a list of all global trace flags that are enabled (Query 6) (Global Trace Flags)
DBCC TRACESTATUS (-1);
 
-- If no global trace flags are enabled, no results will be returned.
-- It is very useful to know what global trace flags are currently enabled as part of the diagnostic process.

-- Common trace flags that should be enabled in most cases
-- TF 3226 - Supresses logging of successful database backup messages to the SQL Server Error Log
-- TF 1118 - Helps alleviate allocation contention in tempdb, SQL Server allocates full extents to each database object, 
--           thereby eliminating the contention on SGAM pages (more important with older versions of SQL Server)
--           Recommendations to reduce allocation contention in SQL Server tempdb database
--           http://support2.microsoft.com/kb/2154845


-- Hardware Information from SQL Server 2005  (Query 7) (Hardware Info)
-- (Cannot distinguish between HT and multi-core)
SELECT cpu_count AS [Logical CPU Count], hyperthread_ratio AS [Hyperthread Ratio],
cpu_count/hyperthread_ratio AS [Physical CPU Count], 
physical_memory_in_bytes/1048576 AS [Physical Memory (MB)]
FROM sys.dm_os_sys_info WITH (NOLOCK) OPTION (RECOMPILE);

-- Gives you some good basic hardware information about your database server


-- Get System Manufacturer and model number from (Query 8) (System Manufacturer)
-- SQL Server Error log. This query might take a few seconds 
-- if you have not recycled your error log recently  
EXEC sys.xp_readerrorlog 0, 1, N'Manufacturer';  

-- This can help you determine the capabilities
-- and capacities of your database server
-- This often comes back with no results on SQL Server 2005


-- Get processor description from Windows Registry  (Query 9) (Processor Description)
EXEC sys.xp_instance_regread N'HKEY_LOCAL_MACHINE', N'HARDWARE\DESCRIPTION\System\CentralProcessor\0', N'ProcessorNameString';

-- Gives you the model number and rated clock speed of your processor(s)
-- Your processors may be running at less that the rated clock speed due
-- to the Windows Power Plan or hardware power management


-- Get configuration values for instance  (Query 10) (Configuration Values)
SELECT name, value, value_in_use, minimum, maximum, [description], is_dynamic, is_advanced
FROM sys.configurations WITH (NOLOCK)
ORDER BY name OPTION (RECOMPILE);

-- Focus on these settings:)
-- backup compression default (should be 1 in most cases)
-- clr enabled (only enable if it is needed)
-- cost threshold for parallelism (depends on your workload)
-- lightweight pooling (should be zero)
-- max degree of parallelism (depends on your workload)
-- max server memory (MB) (set to an appropriate value, not the default)
-- priority boost (should be zero)
-- remote admin connections (should be 1)


-- File Names and Paths for TempDB and all user databases in instance (Query 11) (Database Filenames and Paths)
SELECT DB_NAME([database_id]) AS [Database Name], 
       [file_id], name, physical_name, type_desc, state_desc,
	   is_percent_growth, growth,
	   CONVERT(bigint, growth/128.0) AS [Growth in MB], 
       CONVERT(bigint, size/128.0) AS [Total Size in MB]
FROM sys.master_files WITH (NOLOCK)
WHERE [database_id] > 4 
AND [database_id] <> 32767
OR [database_id] = 2
ORDER BY DB_NAME([database_id]) OPTION (RECOMPILE);

-- Things to look at:
-- Are data files and log files on different drives?
-- Is everything on the C: drive?
-- Is TempDB on dedicated drives?
-- Is there only one TempDB data file?
-- Are all of the TempDB data files the same size?
-- Are there multiple data files for user databases?
-- Is percent growth enabled for any files (which is bad)?


-- Look for I/O requests taking longer than 15 seconds in the five most recent SQL Server Error Logs (Query 12) (IO Warnings)
CREATE TABLE #IOWarningResults(LogDate datetime, ProcessInfo sysname, LogText nvarchar(1000));

	INSERT INTO #IOWarningResults 
	EXEC xp_readerrorlog 0, 1, N'taking longer than 15 seconds';

	INSERT INTO #IOWarningResults 
	EXEC xp_readerrorlog 1, 1, N'taking longer than 15 seconds';

	INSERT INTO #IOWarningResults 
	EXEC xp_readerrorlog 2, 1, N'taking longer than 15 seconds';

	INSERT INTO #IOWarningResults 
	EXEC xp_readerrorlog 3, 1, N'taking longer than 15 seconds';

	INSERT INTO #IOWarningResults 
	EXEC xp_readerrorlog 4, 1, N'taking longer than 15 seconds';

SELECT LogDate, ProcessInfo, LogText
FROM #IOWarningResults
ORDER BY LogDate DESC;

DROP TABLE #IOWarningResults;  

-- Finding 15 second I/O warnings in the SQL Server Error Log is useful evidence of
-- poor I/O performance (which might have many different causes)


-- Drive level latency information (Query 13) (Drive Level Latency)
-- Based on code from Jimmy May
SELECT [Drive],
	CASE 
		WHEN num_of_reads = 0 THEN 0 
		ELSE (io_stall_read_ms/num_of_reads) 
	END AS [Read Latency],
	CASE 
		WHEN io_stall_write_ms = 0 THEN 0 
		ELSE (io_stall_write_ms/num_of_writes) 
	END AS [Write Latency],
	CASE 
		WHEN (num_of_reads = 0 AND num_of_writes = 0) THEN 0 
		ELSE (io_stall/(num_of_reads + num_of_writes)) 
	END AS [Overall Latency],
	CASE 
		WHEN num_of_reads = 0 THEN 0 
		ELSE (num_of_bytes_read/num_of_reads) 
	END AS [Avg Bytes/Read],
	CASE 
		WHEN io_stall_write_ms = 0 THEN 0 
		ELSE (num_of_bytes_written/num_of_writes) 
	END AS [Avg Bytes/Write],
	CASE 
		WHEN (num_of_reads = 0 AND num_of_writes = 0) THEN 0 
		ELSE ((num_of_bytes_read + num_of_bytes_written)/(num_of_reads + num_of_writes)) 
	END AS [Avg Bytes/Transfer]
FROM (SELECT LEFT(UPPER(mf.physical_name), 2) AS Drive, SUM(num_of_reads) AS num_of_reads,
	         SUM(io_stall_read_ms) AS io_stall_read_ms, SUM(num_of_writes) AS num_of_writes,
	         SUM(io_stall_write_ms) AS io_stall_write_ms, SUM(num_of_bytes_read) AS num_of_bytes_read,
	         SUM(num_of_bytes_written) AS num_of_bytes_written, SUM(io_stall) AS io_stall
      FROM sys.dm_io_virtual_file_stats(NULL, NULL) AS vfs
      INNER JOIN sys.master_files AS mf WITH (NOLOCK)
      ON vfs.database_id = mf.database_id AND vfs.file_id = mf.file_id
      GROUP BY LEFT(UPPER(mf.physical_name), 2)) AS tab
ORDER BY [Overall Latency] OPTION (RECOMPILE);

-- Shows you the drive-level latency for reads and writes, in milliseconds
-- Latency above 20-25ms is usually a problem


-- Calculates average stalls per read, per write, and per total input/output for each database file  (Query 14) (IO Stalls by File)
SELECT DB_NAME(fs.database_id) AS [Database Name], CAST(fs.io_stall_read_ms/(1.0 + fs.num_of_reads) AS NUMERIC(10,1)) AS [avg_read_stall_ms],
CAST(fs.io_stall_write_ms/(1.0 + fs.num_of_writes) AS NUMERIC(10,1)) AS [avg_write_stall_ms],
CAST((fs.io_stall_read_ms + fs.io_stall_write_ms)/(1.0 + fs.num_of_reads + fs.num_of_writes) AS NUMERIC(10,1)) AS [avg_io_stall_ms],
CONVERT(DECIMAL(18,2), mf.size/128.0) AS [File Size (MB)], mf.physical_name, mf.type_desc, fs.io_stall_read_ms, fs.num_of_reads, 
fs.io_stall_write_ms, fs.num_of_writes, fs.io_stall_read_ms + fs.io_stall_write_ms AS [io_stalls], fs.num_of_reads + fs.num_of_writes AS [total_io]
FROM sys.dm_io_virtual_file_stats(null,null) AS fs
INNER JOIN sys.master_files AS mf WITH (NOLOCK)
ON fs.database_id = mf.database_id
AND fs.[file_id] = mf.[file_id]
ORDER BY avg_io_stall_ms DESC OPTION (RECOMPILE);

-- Helps determine which database files on the entire instance have the most I/O bottlenecks
-- This can help you decide whether certain LUNs are overloaded and whether you might
-- want to move some files to a different location or perhaps improve your I/O performance


-- Recovery model, log reuse wait description, log file size, log usage size (Query 15) (Database Properties)
-- and compatibility level for all databases on instance
SELECT db.[name] AS [Database Name], db.recovery_model_desc AS [Recovery Model], 
db.log_reuse_wait_desc AS [Log Reuse Wait Description], 
ls.cntr_value AS [Log Size (KB)], lu.cntr_value AS [Log Used (KB)],
CAST(CAST(lu.cntr_value AS FLOAT) / CAST(ls.cntr_value AS FLOAT)AS DECIMAL(18,2)) * 100 AS [Log Used %], 
db.[compatibility_level] AS [DB Compatibility Level], 
db.page_verify_option_desc AS [Page Verify Option], db.is_auto_create_stats_on, db.is_auto_update_stats_on,
db.is_auto_update_stats_async_on, db.is_parameterization_forced, 
db.snapshot_isolation_state_desc, db.is_read_committed_snapshot_on,
db.is_auto_close_on, db.is_auto_shrink_on
FROM sys.databases AS db WITH (NOLOCK)
INNER JOIN sys.dm_os_performance_counters AS lu WITH (NOLOCK)
ON db.name = lu.instance_name
INNER JOIN sys.dm_os_performance_counters AS ls WITH (NOLOCK)
ON db.name = ls.instance_name
WHERE lu.counter_name LIKE N'Log File(s) Used Size (KB)%' 
AND ls.counter_name LIKE N'Log File(s) Size (KB)%'
AND ls.cntr_value > 0 OPTION (RECOMPILE);

-- Things to look at:
-- How many databases are on the instance?
-- What recovery models are they using?
-- What is the log reuse wait description?
-- How full are the transaction logs ?
-- What compatibility level are the databases on? 
-- What is the Page Verify Option? (should be CHECKSUM)
-- Is Auto Update Statistics Asynchronously enabled?
-- Make sure auto_shrink and auto_close are not enabled!



-- Missing Indexes for all databases by Index Advantage  (Query 16) (Missing Indexes All Databases)
SELECT CONVERT(decimal(18,2), user_seeks * avg_total_user_cost * (avg_user_impact * 0.01)) AS [index_advantage], 
migs.last_user_seek, mid.[statement] AS [Database.Schema.Table],
mid.equality_columns, mid.inequality_columns, mid.included_columns,
migs.unique_compiles, migs.user_seeks, migs.avg_total_user_cost, migs.avg_user_impact
FROM sys.dm_db_missing_index_group_stats AS migs WITH (NOLOCK)
INNER JOIN sys.dm_db_missing_index_groups AS mig WITH (NOLOCK)
ON migs.group_handle = mig.index_group_handle
INNER JOIN sys.dm_db_missing_index_details AS mid WITH (NOLOCK)
ON mig.index_handle = mid.index_handle
ORDER BY index_advantage DESC OPTION (RECOMPILE);

-- Getting missing index information for all of the databases on the instance is very useful
-- Look at last user seek time, number of user seeks to help determine source and importance
-- Also look at avg_user_impact and avg_total_user_cost to help determine importance
-- SQL Server is overly eager to add included columns, so beware
-- Do not just blindly add indexes that show up from this query!!!



-- Get VLF Counts for all databases on the instance (Query 17) (VLF Counts)
-- (adapted from Michelle Ufford) 
CREATE TABLE #VLFInfo (FileID  int,
					   FileSize bigint, StartOffset bigint,
					   FSeqNo      bigint, [Status]    bigint,
					   Parity      bigint, CreateLSN   numeric(38));
	 
CREATE TABLE #VLFCountResults(DatabaseName sysname, VLFCount int);
	 
EXEC sp_MSforeachdb N'Use [?]; 

				INSERT INTO #VLFInfo 
				EXEC sp_executesql N''DBCC LOGINFO([?])''; 
	 
				INSERT INTO #VLFCountResults 
				SELECT DB_NAME(), COUNT(*) 
				FROM #VLFInfo; 

				TRUNCATE TABLE #VLFInfo;'
	 
SELECT DatabaseName, VLFCount  
FROM #VLFCountResults
ORDER BY VLFCount DESC;
	 
DROP TABLE #VLFInfo;
DROP TABLE #VLFCountResults;

-- High VLF counts can affect write performance 
-- and they can make database restores and recovery take much longer
-- Try to keep your VLF counts under 200 in most cases



-- Get CPU utilization by database (Query 18) (CPU Usage by Database)
WITH DB_CPU_Stats
AS
(SELECT pa.DatabaseID, DB_Name(pa.DatabaseID) AS [Database Name], SUM(qs.total_worker_time/1000) AS [CPU_Time_Ms]
 FROM sys.dm_exec_query_stats AS qs WITH (NOLOCK)
 CROSS APPLY (SELECT CONVERT(int, value) AS [DatabaseID] 
              FROM sys.dm_exec_plan_attributes(qs.plan_handle)
              WHERE attribute = N'dbid') AS pa
 GROUP BY DatabaseID)
SELECT ROW_NUMBER() OVER(ORDER BY [CPU_Time_Ms] DESC) AS [CPU Rank],
       [Database Name], [CPU_Time_Ms] AS [CPU Time (ms)], 
       CAST([CPU_Time_Ms] * 1.0 / SUM([CPU_Time_Ms]) OVER() * 100.0 AS DECIMAL(5, 2)) AS [CPU Percent]
FROM DB_CPU_Stats
WHERE DatabaseID <> 32767 -- ResourceDB
ORDER BY [CPU Rank] OPTION (RECOMPILE);

-- Helps determine which database is using the most CPU resources on the instance


-- Get I/O utilization by database (Query 19) (IO Usage By Database)
WITH Aggregate_IO_Statistics
AS
(SELECT DB_NAME(database_id) AS [Database Name],
CAST(SUM(num_of_bytes_read + num_of_bytes_written)/1048576 AS DECIMAL(12, 2)) AS io_in_mb
FROM sys.dm_io_virtual_file_stats(NULL, NULL) AS [DM_IO_STATS]
GROUP BY database_id)
SELECT ROW_NUMBER() OVER(ORDER BY io_in_mb DESC) AS [I/O Rank], [Database Name], io_in_mb AS [Total I/O (MB)],
       CAST(io_in_mb/ SUM(io_in_mb) OVER() * 100.0 AS DECIMAL(5,2)) AS [I/O Percent]
FROM Aggregate_IO_Statistics
ORDER BY [I/O Rank] OPTION (RECOMPILE);

-- Helps determine which database is using the most I/O resources on the instance


-- Get total buffer usage by database for current instance (Query 20) (Total Buffer Usage by Database)
-- This make take some time to run on a busy instance
WITH AggregateBufferPoolUsage
AS
(SELECT DB_NAME(database_id) AS [Database Name],
CAST(COUNT(*) * 8/1024.0 AS DECIMAL (10,2))  AS [CachedSize]
FROM sys.dm_os_buffer_descriptors WITH (NOLOCK)
WHERE database_id <> 32767 -- ResourceDB
GROUP BY DB_NAME(database_id))
SELECT ROW_NUMBER() OVER(ORDER BY CachedSize DESC) AS [Buffer Pool Rank], [Database Name], CachedSize AS [Cached Size (MB)],
       CAST(CachedSize / SUM(CachedSize) OVER() * 100.0 AS DECIMAL(5,2)) AS [Buffer Pool Percent]
FROM AggregateBufferPoolUsage
ORDER BY [Buffer Pool Rank] OPTION (RECOMPILE);

-- Tells you how much memory (in the buffer pool) 
-- is being used by each database on the instance


-- Clear Wait Stats with this command
-- DBCC SQLPERF('sys.dm_os_wait_stats', CLEAR);

-- Isolate top waits for server instance since last restart or statistics clear (Query 21) (Top Waits)
WITH [Waits] 
AS (SELECT wait_type, wait_time_ms/ 1000.0 AS [WaitS],
          (wait_time_ms - signal_wait_time_ms) / 1000.0 AS [ResourceS],
           signal_wait_time_ms / 1000.0 AS [SignalS],
           waiting_tasks_count AS [WaitCount],
           100.0 *  wait_time_ms / SUM (wait_time_ms) OVER() AS [Percentage],
           ROW_NUMBER() OVER(ORDER BY wait_time_ms DESC) AS [RowNum]
    FROM sys.dm_os_wait_stats WITH (NOLOCK)
    WHERE [wait_type] NOT IN (
        N'BROKER_EVENTHANDLER', N'BROKER_RECEIVE_WAITFOR', N'BROKER_TASK_STOP',
		N'BROKER_TO_FLUSH', N'BROKER_TRANSMITTER', N'CHECKPOINT_QUEUE',
        N'CHKPT', N'CLR_AUTO_EVENT', N'CLR_MANUAL_EVENT', N'CLR_SEMAPHORE',
        N'DBMIRROR_DBM_EVENT', N'DBMIRROR_EVENTS_QUEUE', N'DBMIRROR_WORKER_QUEUE',
		N'DBMIRRORING_CMD', N'DIRTY_PAGE_POLL', N'DISPATCHER_QUEUE_SEMAPHORE',
        N'EXECSYNC', N'FSAGENT', N'FT_IFTS_SCHEDULER_IDLE_WAIT', N'FT_IFTSHC_MUTEX',
        N'HADR_CLUSAPI_CALL', N'HADR_FILESTREAM_IOMGR_IOCOMPLETION', N'HADR_LOGCAPTURE_WAIT', 
		N'HADR_NOTIFICATION_DEQUEUE', N'HADR_TIMER_TASK', N'HADR_WORK_QUEUE',
        N'KSOURCE_WAKEUP', N'LAZYWRITER_SLEEP', N'LOGMGR_QUEUE', N'ONDEMAND_TASK_QUEUE',
        N'PWAIT_ALL_COMPONENTS_INITIALIZED', N'QDS_PERSIST_TASK_MAIN_LOOP_SLEEP',
        N'QDS_CLEANUP_STALE_QUERIES_TASK_MAIN_LOOP_SLEEP', N'REQUEST_FOR_DEADLOCK_SEARCH',
		N'RESOURCE_QUEUE', N'SERVER_IDLE_CHECK', N'SLEEP_BPOOL_FLUSH', N'SLEEP_DBSTARTUP',
		N'SLEEP_DCOMSTARTUP', N'SLEEP_MASTERDBREADY', N'SLEEP_MASTERMDREADY',
        N'SLEEP_MASTERUPGRADED', N'SLEEP_MSDBSTARTUP', N'SLEEP_SYSTEMTASK', N'SLEEP_TASK',
        N'SLEEP_TEMPDBSTARTUP', N'SNI_HTTP_ACCEPT', N'SP_SERVER_DIAGNOSTICS_SLEEP',
		N'SQLTRACE_BUFFER_FLUSH', N'SQLTRACE_INCREMENTAL_FLUSH_SLEEP', N'SQLTRACE_WAIT_ENTRIES',
		N'WAIT_FOR_RESULTS', N'WAITFOR', N'WAITFOR_TASKSHUTDOWN', N'WAIT_XTP_HOST_WAIT',
		N'WAIT_XTP_OFFLINE_CKPT_NEW_LOG', N'WAIT_XTP_CKPT_CLOSE', N'XE_DISPATCHER_JOIN',
        N'XE_DISPATCHER_WAIT', N'XE_TIMER_EVENT')
    AND waiting_tasks_count > 0)
SELECT
    MAX (W1.wait_type) AS [WaitType],
    CAST (MAX (W1.WaitS) AS DECIMAL (16,2)) AS [Wait_Sec],
    CAST (MAX (W1.ResourceS) AS DECIMAL (16,2)) AS [Resource_Sec],
    CAST (MAX (W1.SignalS) AS DECIMAL (16,2)) AS [Signal_Sec],
    MAX (W1.WaitCount) AS [Wait Count],
    CAST (MAX (W1.Percentage) AS DECIMAL (5,2)) AS [Wait Percentage],
    CAST ((MAX (W1.WaitS) / MAX (W1.WaitCount)) AS DECIMAL (16,4)) AS [AvgWait_Sec],
    CAST ((MAX (W1.ResourceS) / MAX (W1.WaitCount)) AS DECIMAL (16,4)) AS [AvgRes_Sec],
    CAST ((MAX (W1.SignalS) / MAX (W1.WaitCount)) AS DECIMAL (16,4)) AS [AvgSig_Sec]
FROM Waits AS W1
INNER JOIN Waits AS W2
ON W2.RowNum <= W1.RowNum
GROUP BY W1.RowNum
HAVING SUM (W2.Percentage) - MAX (W1.Percentage) < 99 -- percentage threshold
OPTION (RECOMPILE);

-- The SQL Server Wait Type Repository
-- http://blogs.msdn.com/b/psssql/archive/2009/11/03/the-sql-server-wait-type-repository.aspx

-- Wait statistics, or please tell me where it hurts
-- http://www.sqlskills.com/blogs/paul/wait-statistics-or-please-tell-me-where-it-hurts/

-- SQL Server 2005 Performance Tuning using the Waits and Queues
-- http://technet.microsoft.com/en-us/library/cc966413.aspx

-- sys.dm_os_wait_stats (Transact-SQL)
-- http://msdn.microsoft.com/en-us/library/ms179984(v=sql.100).aspx



-- Signal Waits for instance  (Query 22) (Signal Waits)
SELECT CAST(100.0 * SUM(signal_wait_time_ms) / SUM (wait_time_ms) AS NUMERIC(20,2)) AS [% Signal (CPU) Waits],
CAST(100.0 * SUM(wait_time_ms - signal_wait_time_ms) / SUM (wait_time_ms) AS NUMERIC(20,2)) AS [% Resource Waits]
FROM sys.dm_os_wait_stats WITH (NOLOCK)
WHERE wait_type NOT IN (
        N'BROKER_EVENTHANDLER', N'BROKER_RECEIVE_WAITFOR', N'BROKER_TASK_STOP',
		N'BROKER_TO_FLUSH', N'BROKER_TRANSMITTER', N'CHECKPOINT_QUEUE',
        N'CHKPT', N'CLR_AUTO_EVENT', N'CLR_MANUAL_EVENT', N'CLR_SEMAPHORE',
        N'DBMIRROR_DBM_EVENT', N'DBMIRROR_EVENTS_QUEUE', N'DBMIRROR_WORKER_QUEUE',
		N'DBMIRRORING_CMD', N'DIRTY_PAGE_POLL', N'DISPATCHER_QUEUE_SEMAPHORE',
        N'EXECSYNC', N'FSAGENT', N'FT_IFTS_SCHEDULER_IDLE_WAIT', N'FT_IFTSHC_MUTEX',
        N'HADR_CLUSAPI_CALL', N'HADR_FILESTREAM_IOMGR_IOCOMPLETION', N'HADR_LOGCAPTURE_WAIT', 
		N'HADR_NOTIFICATION_DEQUEUE', N'HADR_TIMER_TASK', N'HADR_WORK_QUEUE',
        N'KSOURCE_WAKEUP', N'LAZYWRITER_SLEEP', N'LOGMGR_QUEUE', N'ONDEMAND_TASK_QUEUE',
        N'PWAIT_ALL_COMPONENTS_INITIALIZED', N'QDS_PERSIST_TASK_MAIN_LOOP_SLEEP',
        N'QDS_CLEANUP_STALE_QUERIES_TASK_MAIN_LOOP_SLEEP', N'REQUEST_FOR_DEADLOCK_SEARCH',
		N'RESOURCE_QUEUE', N'SERVER_IDLE_CHECK', N'SLEEP_BPOOL_FLUSH', N'SLEEP_DBSTARTUP',
		N'SLEEP_DCOMSTARTUP', N'SLEEP_MASTERDBREADY', N'SLEEP_MASTERMDREADY',
        N'SLEEP_MASTERUPGRADED', N'SLEEP_MSDBSTARTUP', N'SLEEP_SYSTEMTASK', N'SLEEP_TASK',
        N'SLEEP_TEMPDBSTARTUP', N'SNI_HTTP_ACCEPT', N'SP_SERVER_DIAGNOSTICS_SLEEP',
		N'SQLTRACE_BUFFER_FLUSH', N'SQLTRACE_INCREMENTAL_FLUSH_SLEEP', N'SQLTRACE_WAIT_ENTRIES',
		N'WAIT_FOR_RESULTS', N'WAITFOR', N'WAITFOR_TASKSHUTDOWN', N'WAIT_XTP_HOST_WAIT',
		N'WAIT_XTP_OFFLINE_CKPT_NEW_LOG', N'WAIT_XTP_CKPT_CLOSE', N'XE_DISPATCHER_JOIN',
        N'XE_DISPATCHER_WAIT', N'XE_TIMER_EVENT') OPTION (RECOMPILE);

-- Signal Waits above 10-15% is usually a confirming sign of CPU pressure
-- Cumulative wait stats are not as useful on an idle instance that is not under load or performance pressure
-- Resource waits are non-CPU related waits


--  Get logins that are connected and how many sessions they have (Query 23) (Connection Counts)
SELECT login_name, [program_name], COUNT(session_id) AS [session_count] 
FROM sys.dm_exec_sessions WITH (NOLOCK)
GROUP BY login_name, [program_name]
ORDER BY COUNT(session_id) DESC OPTION (RECOMPILE);

-- This can help characterize your workload and
-- determine whether you are seeing a normal level of activity


-- Get a count of SQL connections by IP address (Query 24) (Connection Counts by IP Address)
SELECT ec.client_net_address, es.[program_name], es.[host_name], es.login_name, 
COUNT(ec.session_id) AS [connection count] 
FROM sys.dm_exec_sessions AS es WITH (NOLOCK) 
INNER JOIN sys.dm_exec_connections AS ec WITH (NOLOCK) 
ON es.session_id = ec.session_id 
GROUP BY ec.client_net_address, es.[program_name], es.[host_name], es.login_name  
ORDER BY ec.client_net_address, es.[program_name] OPTION (RECOMPILE);

-- This helps you figure where your database load is coming from
-- and verifies connectivity from other machines


-- Get Average Task Counts (run multiple times) (Query 25) (Avg Task Counts)
SELECT AVG(current_tasks_count) AS [Avg Task Count], 
AVG(runnable_tasks_count) AS [Avg Runnable Task Count],
AVG(pending_disk_io_count) AS [AvgPendingDiskIOCount]
FROM sys.dm_os_schedulers WITH (NOLOCK)
WHERE scheduler_id < 255 OPTION (RECOMPILE);

-- Sustained values above 10 suggest further investigation in that area
-- High Avg Task Counts are often caused by blocking/deadlocking or other resource contention

-- Sustained values above 1 suggest further investigation in that area
-- High Avg Runnable Task Counts are a good sign of CPU pressure
-- High Avg Pending DiskIO Counts are a sign of disk pressure


-- Get CPU Utilization History for last 256 minutes (in one minute intervals) (Query 26) (CPU Utilization History)
-- This version works with SQL Server 2005
DECLARE @ts_now bigint; 
SET @ts_now = (SELECT cpu_ticks / CONVERT(float, cpu_ticks_in_ms) FROM sys.dm_os_sys_info WITH (NOLOCK)); 

SELECT TOP(256) SQLProcessUtilization AS [SQL Server Process CPU Utilization], 
               SystemIdle AS [System Idle Process], 
               100 - SystemIdle - SQLProcessUtilization AS [Other Process CPU Utilization], 
               DATEADD(ms, -1 * (@ts_now - [timestamp]), GETDATE()) AS [Event Time] 
FROM ( 
	  SELECT record.value('(./Record/@id)[1]', 'int') AS record_id, 
			record.value('(./Record/SchedulerMonitorEvent/SystemHealth/SystemIdle)[1]', 'int') 
			AS [SystemIdle], 
			record.value('(./Record/SchedulerMonitorEvent/SystemHealth/ProcessUtilization)[1]', 
			'int') 
			AS [SQLProcessUtilization], [timestamp] 
	  FROM ( 
			SELECT [timestamp], CONVERT(xml, record) AS [record] 
			FROM sys.dm_os_ring_buffers WITH (NOLOCK)
			WHERE ring_buffer_type = N'RING_BUFFER_SCHEDULER_MONITOR' 
			AND record LIKE '%<SystemHealth>%') AS x 
	  ) AS y 
ORDER BY record_id DESC OPTION (RECOMPILE);

-- Look at the trend over the entire period. 
-- Also look at high sustained Other Process CPU Utilization values


-- Page Life Expectancy (PLE) value for each NUMA node in current instance  (Query 27) (PLE by NUMA Node)
SELECT @@SERVERNAME AS [Server Name], [object_name], instance_name, cntr_value AS [Page Life Expectancy]
FROM sys.dm_os_performance_counters WITH (NOLOCK)
WHERE [object_name] LIKE N'%Buffer Node%' -- Handles named instances
AND counter_name = N'Page life expectancy' OPTION (RECOMPILE);

-- PLE is a good measurement of memory pressure.
-- Higher PLE is better. Watch the trend over time, not the absolute value.
-- This will only return one row for non-NUMA systems.


-- Memory Grants Pending value for current instance (Query 28) (Memory Grants Pending)
SELECT @@SERVERNAME AS [Server Name], [object_name], cntr_value AS [Memory Grants Pending]                                                                                                       
FROM sys.dm_os_performance_counters WITH (NOLOCK)
WHERE [object_name] LIKE N'%Memory Manager%' -- Handles named instances
AND counter_name = N'Memory Grants Pending' OPTION (RECOMPILE);

-- Memory Grants Pending above zero for a sustained period is a very strong indicator of memory pressure


-- Memory Clerk Usage for instance  (Query 29) (Memory Clerk Usage)
-- Look for high value for CACHESTORE_SQLCP (Ad-hoc query plans)
SELECT TOP(10) [type] AS [Memory Clerk Type], SUM(single_pages_kb)/1024 AS [SPA Memory Usage (MB)] 
FROM sys.dm_os_memory_clerks WITH (NOLOCK)
GROUP BY [type]  
ORDER BY SUM(single_pages_kb) DESC OPTION (RECOMPILE);

-- CACHESTORE_SQLCP  SQL Plans         
-- These are cached SQL statements or batches that aren't in stored procedures, functions and triggers
-- Watch out for high values for CACHESTORE_SQLCP

-- CACHESTORE_OBJCP  Object Plans      
-- These are compiled plans for stored procedures, functions and triggers



-- Find single-use, ad-hoc queries that are bloating the plan cache (Query 30) (Ad hoc Queries)
SELECT TOP(50) [text] AS [QueryText], cp.cacheobjtype, cp.objtype, cp.size_in_bytes/1024 AS [Plan Size in KB]
FROM sys.dm_exec_cached_plans AS cp WITH (NOLOCK)
CROSS APPLY sys.dm_exec_sql_text(plan_handle) 
WHERE cp.cacheobjtype = N'Compiled Plan' 
AND cp.objtype IN (N'Adhoc', N'Prepared') 
AND cp.usecounts = 1
ORDER BY cp.size_in_bytes DESC OPTION (RECOMPILE);

-- Gives you the text and size of single-use ad-hoc queries that waste space in plan cache
-- SQL Server Agent creates lots of ad-hoc, single use query plans in SQL Server 2005
-- Running DBCC FREESYSTEMCACHE ('SQL Plans') periodically may be required to better control this.
-- Enabling forced parameterization for the database can help, but test first!



-- Switch to user database *******************
--USE YourDatabaseName;
--GO

-- Individual File Sizes and space available for current database  (Query 31) (File Sizes and Space)
SELECT f.name AS [File Name] , f.physical_name AS [Physical Name], 
CAST((f.size/128.0) AS DECIMAL(15,2)) AS [Total Size in MB],
CAST(f.size/128.0 - CAST(FILEPROPERTY(f.name, 'SpaceUsed') AS int)/128.0 AS DECIMAL(15,2)) 
AS [Available Space In MB], [file_id], fg.name AS [Filegroup Name]
FROM sys.database_files AS f WITH (NOLOCK) 
LEFT OUTER JOIN sys.data_spaces AS fg WITH (NOLOCK) 
ON f.data_space_id = fg.data_space_id OPTION (RECOMPILE);

-- Look at how large and how full the files are and where they are located
-- Make sure the transaction log is not full!!



-- I/O Statistics by file for the current database  (Query 32) (IO Stats By File)
SELECT DB_NAME(DB_ID()) AS [Database Name], df.name AS [Logical Name], vfs.[file_id], 
df.physical_name AS [Physical Name], vfs.num_of_reads, vfs.num_of_writes, vfs.io_stall_read_ms, vfs.io_stall_write_ms,
CAST(100. * vfs.io_stall_read_ms/(vfs.io_stall_read_ms + vfs.io_stall_write_ms) AS DECIMAL(10,1)) AS [IO Stall Reads Pct],
CAST(100. * vfs.io_stall_write_ms/(vfs.io_stall_write_ms + vfs.io_stall_read_ms) AS DECIMAL(10,1)) AS [IO Stall Writes Pct],
(vfs.num_of_reads + vfs.num_of_writes) AS [Writes + Reads], 
CAST(vfs.num_of_bytes_read/1048576.0 AS DECIMAL(10, 2)) AS [MB Read], 
CAST(vfs.num_of_bytes_written/1048576.0 AS DECIMAL(10, 2)) AS [MB Written],
CAST(100. * vfs.num_of_reads/(vfs.num_of_reads + vfs.num_of_writes) AS DECIMAL(10,1)) AS [# Reads Pct],
CAST(100. * vfs.num_of_writes/(vfs.num_of_reads + vfs.num_of_writes) AS DECIMAL(10,1)) AS [# Write Pct],
CAST(100. * vfs.num_of_bytes_read/(vfs.num_of_bytes_read + vfs.num_of_bytes_written) AS DECIMAL(10,1)) AS [Read Bytes Pct],
CAST(100. * vfs.num_of_bytes_written/(vfs.num_of_bytes_read + vfs.num_of_bytes_written) AS DECIMAL(10,1)) AS [Written Bytes Pct]
FROM sys.dm_io_virtual_file_stats(DB_ID(), NULL) AS vfs
INNER JOIN sys.database_files AS df WITH (NOLOCK)
ON vfs.[file_id]= df.[file_id] OPTION (RECOMPILE);

-- This helps you characterize your workload better from an I/O perspective
-- It helps you determine whether you has an OLTP or DW/DSS type of workload



-- Cached SP's By Execution Count (SQL 2005)  (Query 33) (SP Execution Counts)
SELECT TOP(25) OBJECT_NAME(objectid, dbid) AS [SP Name], qt.[text] AS [SP Text], 
qs.execution_count AS [Execution Count],  
qs.execution_count/DATEDIFF(Minute, qs.creation_time, GETDATE()) AS [Calls/Minute],
qs.total_worker_time/qs.execution_count AS [AvgWorkerTime],
qs.total_worker_time AS [TotalWorkerTime],
qs.total_elapsed_time/qs.execution_count AS [AvgElapsedTime],
qs.max_logical_reads, qs.max_logical_writes, qs.total_physical_reads, 
DATEDIFF(Minute, qs.creation_time, GetDate()) AS [Age in Cache]
FROM sys.dm_exec_query_stats AS qs WITH (NOLOCK)
CROSS APPLY sys.dm_exec_sql_text(qs.[sql_handle]) AS qt
WHERE qt.[dbid] = DB_ID() 
ORDER BY qs.execution_count DESC OPTION (RECOMPILE);

-- Tells you which cached stored procedures are called the most often
-- This helps you characterize and baseline your workload


-- Top Cached SPs By Avg Elapsed Time (SQL 2005)  (Query 34) (SP Avg Elapsed Time)
SELECT TOP(25) OBJECT_NAME(objectid, dbid) AS [SP Name], qt.[text] AS [SP Text],  
ISNULL(qs.total_elapsed_time/qs.execution_count, 0) AS [AvgElapsedTime], 
qs.execution_count AS [Execution Count], qs.total_worker_time AS [TotalWorkerTime], 
qs.total_worker_time/qs.execution_count AS [AvgWorkerTime],
ISNULL(qs.execution_count/DATEDIFF(Minute, qs.creation_time, GETDATE()), 0) AS [Calls/Minute],
qs.max_logical_reads, qs.max_logical_writes, 
DATEDIFF(Minute, qs.creation_time, GETDATE()) AS [Age in Cache]
FROM sys.dm_exec_query_stats AS qs WITH (NOLOCK)
CROSS APPLY sys.dm_exec_sql_text(qs.[sql_handle]) AS qt
WHERE qt.[dbid] = DB_ID() 
ORDER BY qs.total_elapsed_time/qs.execution_count DESC OPTION (RECOMPILE);

-- This helps you find long-running cached stored procedures that
-- may be easy to optimize with standard query tuning techniques

-- Cached SP's By Worker Time (SQL 2005) Worker time relates to CPU cost  (Query 35) (SP Worker Time)
SELECT TOP(25) OBJECT_NAME(objectid, dbid) AS [SP Name], qt.[text] AS [SP Text], 
qs.total_worker_time AS [TotalWorkerTime], qs.total_worker_time/qs.execution_count AS [AvgWorkerTime],
qs.execution_count AS [Execution Count], 
ISNULL(qs.execution_count/DATEDIFF(Minute, qs.creation_time, GETDATE()), 0) AS [Calls/Minute],
ISNULL(qs.total_elapsed_time/qs.execution_count, 0) AS [AvgElapsedTime], 
qs.max_logical_reads, qs.max_logical_writes, 
DATEDIFF(Minute, qs.creation_time, GETDATE()) AS [Age in Cache]
FROM sys.dm_exec_query_stats AS qs WITH (NOLOCK)
CROSS APPLY sys.dm_exec_sql_text(qs.[sql_handle]) AS qt
WHERE qt.[dbid] = DB_ID() 
ORDER BY qs.total_worker_time DESC OPTION (RECOMPILE);

-- This helps you find the most expensive cached stored procedures from a CPU perspective
-- You should look at this if you see signs of CPU pressure

-- Cached SP's By Logical Reads (SQL 2005) Logical reads relate to memory pressure  (Query 36) (SP Logical Reads)
SELECT TOP(25) OBJECT_NAME(objectid, dbid) AS [SP Name], qt.[text] AS [SP Text],  
total_logical_reads, qs.max_logical_reads,
total_logical_reads/qs.execution_count AS [AvgLogicalReads], qs.execution_count AS [Execution Count], 
qs.execution_count/DATEDIFF(Minute, qs.creation_time, GETDATE()) AS [Calls/Minute], 
qs.total_worker_time/qs.execution_count AS [AvgWorkerTime],
qs.total_worker_time AS [TotalWorkerTime],
qs.total_elapsed_time/qs.execution_count AS [AvgElapsedTime],
qs.total_logical_writes,
 qs.max_logical_writes, qs.total_physical_reads, 
DATEDIFF(Minute, qs.creation_time, GETDATE()) AS [Age in Cache]
FROM sys.dm_exec_query_stats AS qs WITH (NOLOCK)
CROSS APPLY sys.dm_exec_sql_text(qs.[sql_handle]) AS qt
WHERE qt.[dbid] = DB_ID() 
ORDER BY total_logical_reads DESC OPTION (RECOMPILE);

-- This helps you find the most expensive cached stored procedures from a memory perspective
-- You should look at this if you see signs of memory pressure


-- Cached SP's By Physical Reads (SQL 2005) Physical reads relate to read I/O pressure  (Query 37) (SP Physical Reads)
SELECT TOP(25) OBJECT_NAME(objectid, dbid) AS [SP Name], qt.[text] AS [SP Text],  
qs.total_physical_reads, total_logical_reads, qs.max_logical_reads,
total_logical_reads/qs.execution_count AS [AvgLogicalReads], qs.execution_count AS [Execution Count], 
qs.execution_count/DATEDIFF(Minute, qs.creation_time, GETDATE()) AS [Calls/Minute], 
qs.total_worker_time/qs.execution_count AS [AvgWorkerTime],
qs.total_worker_time AS [TotalWorkerTime],
qs.total_elapsed_time/qs.execution_count AS [AvgElapsedTime],
DATEDIFF(Minute, qs.creation_time, GETDATE()) AS [Age in Cache]
FROM sys.dm_exec_query_stats AS qs WITH (NOLOCK)
CROSS APPLY sys.dm_exec_sql_text(qs.[sql_handle]) AS qt
WHERE qt.[dbid] = DB_ID() -- Filter by current database
AND qs.total_physical_reads > 0
ORDER BY qs.total_physical_reads DESC OPTION (RECOMPILE);

-- This helps you find the most expensive cached stored procedures from a read I/O perspective
-- You should look at this if you see signs of I/O pressure or of memory pressure


-- Top Cached SPs By Total Logical Writes (SQL 2005)  (Query 38) (SP Logical Writes)
-- Logical writes relate to both memory and disk I/O pressure 
SELECT TOP(25) OBJECT_NAME(objectid, dbid) AS [SP Name], qt.[text] AS [SP Text],  
qs.total_logical_writes, qs.max_logical_writes,
qs.total_logical_writes/qs.execution_count AS [AvgLogicalWrites], qs.execution_count AS [Execution Count], 
qs.execution_count/DATEDIFF(Minute, qs.creation_time, GETDATE()) AS [Calls/Minute], 
qs.total_worker_time/qs.execution_count AS [AvgWorkerTime],
qs.total_worker_time AS [TotalWorkerTime],
qs.total_elapsed_time/qs.execution_count AS [AvgElapsedTime],
qs.total_physical_reads, 
DATEDIFF(Minute, qs.creation_time, GETDATE()) AS [Age in Cache]
FROM sys.dm_exec_query_stats AS qs WITH (NOLOCK)
CROSS APPLY sys.dm_exec_sql_text(qs.[sql_handle]) AS qt
WHERE qt.[dbid] = DB_ID()
AND qs.total_logical_writes > 0 
ORDER BY total_logical_writes DESC OPTION (RECOMPILE);

-- This helps you find the most expensive cached stored procedures from a write I/O perspective
-- You should look at this if you see signs of I/O pressure or of memory pressure


-- Lists the top statements by average input/output usage for the current database  (Query 39) (Top IO Statements)
SELECT TOP(50) OBJECT_NAME(qt.objectid, dbid) AS [SP Name],
(qs.total_logical_reads + qs.total_logical_writes) /qs.execution_count AS [Avg IO], qs.execution_count AS [Execution Count],
SUBSTRING(qt.[text],qs.statement_start_offset/2, 
	(CASE 
		WHEN qs.statement_end_offset = -1 
	 THEN LEN(CONVERT(nvarchar(max), qt.[text])) * 2 
		ELSE qs.statement_end_offset 
	 END - qs.statement_start_offset)/2) AS [Query Text]	
FROM sys.dm_exec_query_stats AS qs WITH (NOLOCK)
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) AS qt
WHERE qt.[dbid] = DB_ID()
ORDER BY [Avg IO] DESC OPTION (RECOMPILE);

-- Helps you find the most expensive statements for I/O by SP



-- Possible Bad NC Indexes (writes > reads)  (Query 40) (Bad NC Indexes)
SELECT OBJECT_NAME(s.[object_id]) AS [Table Name], i.name AS [Index Name], 
o.[type_desc], o.create_date, i.index_id, i.is_disabled,
user_updates AS [Total Writes], user_seeks + user_scans + user_lookups AS [Total Reads],
user_updates - (user_seeks + user_scans + user_lookups) AS [Difference]
FROM sys.dm_db_index_usage_stats AS s WITH (NOLOCK)
INNER JOIN sys.indexes AS i WITH (NOLOCK)
ON s.[object_id] = i.[object_id]
AND i.index_id = s.index_id
INNER JOIN sys.objects AS o WITH (NOLOCK) 
ON i.[object_id] = o.[object_id]
WHERE OBJECTPROPERTY(s.[object_id],'IsUserTable') = 1
AND s.database_id = DB_ID()
AND user_updates > (user_seeks + user_scans + user_lookups)
AND i.index_id > 1
ORDER BY [Difference] DESC, [Total Writes] DESC, [Total Reads] ASC OPTION (RECOMPILE);

-- Look for indexes with high numbers of writes and zero or very low numbers of reads
-- Consider your complete workload, and how long your instance has been running
-- Investigate further before dropping an index!


-- Missing Indexes for current database by Index Advantage  (Query 41) (Missing Indexes)
SELECT DISTINCT CONVERT(decimal(18,2), user_seeks * avg_total_user_cost * (avg_user_impact * 0.01)) AS [index_advantage], 
migs.last_user_seek, mid.[statement] AS [Database.Schema.Table],
mid.equality_columns, mid.inequality_columns, mid.included_columns,
migs.unique_compiles, migs.user_seeks, migs.avg_total_user_cost, migs.avg_user_impact,
OBJECT_NAME(mid.[object_id]) AS [Table Name], p.rows AS [Table Rows]
FROM sys.dm_db_missing_index_group_stats AS migs WITH (NOLOCK)
INNER JOIN sys.dm_db_missing_index_groups AS mig WITH (NOLOCK)
ON migs.group_handle = mig.index_group_handle
INNER JOIN sys.dm_db_missing_index_details AS mid WITH (NOLOCK)
ON mig.index_handle = mid.index_handle
INNER JOIN sys.partitions AS p WITH (NOLOCK)
ON p.[object_id] = mid.[object_id]
WHERE mid.database_id = DB_ID() 
ORDER BY index_advantage DESC OPTION (RECOMPILE);

-- Look at index advantage, last user seek time, number of user seeks to help determine source and importance
-- SQL Server is overly eager to add included columns, so beware
-- Do not just blindly add indexes that show up from this query!!!


-- Find missing index warnings for cached plans in the current database  (Query 42) (Missing Index Warnings)
-- Note: This query could take some time on a busy instance
SELECT TOP(25) OBJECT_NAME(objectid) AS [ObjectName], 
               query_plan, cp.objtype, cp.usecounts
FROM sys.dm_exec_cached_plans AS cp WITH (NOLOCK)
CROSS APPLY sys.dm_exec_query_plan(cp.plan_handle) AS qp
WHERE CAST(query_plan AS NVARCHAR(MAX)) LIKE N'%MissingIndex%'
AND dbid = DB_ID()
ORDER BY cp.usecounts DESC OPTION (RECOMPILE);

-- Helps you connect missing indexes to specific stored procedures
-- This can help you decide whether to add them or not


-- Breaks down buffers used by current database by object (table, index) in the buffer cache  (Query 43) (Buffer Usage)
-- Note: This query could take some time on a busy instance
SELECT OBJECT_NAME(p.[object_id]) AS [ObjectName], 
p.index_id, COUNT(*)/128 AS [buffer size(MB)],  COUNT(*) AS [buffer_count] 
FROM sys.allocation_units AS a
INNER JOIN sys.dm_os_buffer_descriptors AS b WITH (NOLOCK)
ON a.allocation_unit_id = b.allocation_unit_id
INNER JOIN sys.partitions AS p WITH (NOLOCK)
ON a.container_id = p.hobt_id
WHERE b.database_id = DB_ID()
AND p.[object_id] > 100
GROUP BY p.[object_id], p.index_id
ORDER BY buffer_count DESC OPTION (RECOMPILE);

-- Tells you what tables and indexes are using the most memory in the buffer cache


-- Get Table names, row counts  (Query 44) (Table Sizes)
SELECT OBJECT_NAME(object_id) AS [ObjectName], SUM(Rows) AS [RowCount]
FROM sys.partitions WITH (NOLOCK)
WHERE index_id < 2 --ignore the partitions from the non-clustered index if any
AND OBJECT_NAME(object_id) NOT LIKE N'sys%'
AND OBJECT_NAME(object_id) NOT LIKE N'queue_%' 
AND OBJECT_NAME(object_id) NOT LIKE N'filestream_tombstone%'
AND OBJECT_NAME(object_id) NOT LIKE N'fulltext%' 
GROUP BY [object_id]
ORDER BY SUM(Rows) DESC OPTION (RECOMPILE);

-- Gives you an idea of table sizes


-- Detect blocking (run multiple times)  (Query 45) (Detect Blocking)
SELECT t1.resource_type AS [lock type], DB_NAME(resource_database_id) AS [database],
t1.resource_associated_entity_id AS [blk object],t1.request_mode AS [lock req],  --- lock requested
t1.request_session_id AS [waiter sid], t2.wait_duration_ms AS [wait time],       -- spid of waiter  
(SELECT [text] FROM sys.dm_exec_requests AS r WITH (NOLOCK)                      -- get sql for waiter
CROSS APPLY sys.dm_exec_sql_text(r.[sql_handle]) 
WHERE r.session_id = t1.request_session_id) AS [waiter_batch],
(SELECT SUBSTRING(qt.[text],r.statement_start_offset/2, 
    (CASE WHEN r.statement_end_offset = -1 
    THEN LEN(CONVERT(nvarchar(max), qt.[text])) * 2 
    ELSE r.statement_end_offset END - r.statement_start_offset)/2) 
FROM sys.dm_exec_requests AS r WITH (NOLOCK)
CROSS APPLY sys.dm_exec_sql_text(r.[sql_handle]) AS qt
WHERE r.session_id = t1.request_session_id) AS [waiter_stmt],					-- statement blocked
t2.blocking_session_id AS [blocker sid],										-- spid of blocker
(SELECT [text] FROM sys.sysprocesses AS p										-- get sql for blocker
CROSS APPLY sys.dm_exec_sql_text(p.[sql_handle]) 
WHERE p.spid = t2.blocking_session_id) AS [blocker_stmt]
FROM sys.dm_tran_locks AS t1 WITH (NOLOCK)
INNER JOIN sys.dm_os_waiting_tasks AS t2 WITH (NOLOCK)
ON t1.lock_owner_address = t2.resource_address OPTION (RECOMPILE);

-- Helps troubleshoot blocking and deadlocking issues
-- The results will change from second to second on a busy system
-- You should run this query multiple times when you see signs of blocking


-- When were Statistics last updated on all indexes?  (Query 46) (Statistics Update)
SELECT SCHEMA_NAME(o.Schema_ID) + N'.' + o.NAME AS [Object Name], o.type_desc AS [Object Type],
      i.name AS [Index Name], STATS_DATE(i.[object_id], i.index_id) AS [Statistics Date], 
      s.auto_created, s.no_recompute, s.user_created, st.row_count, st.used_page_count
FROM sys.objects AS o WITH (NOLOCK)
INNER JOIN sys.indexes AS i WITH (NOLOCK)
ON o.[object_id] = i.[object_id]
INNER JOIN sys.stats AS s WITH (NOLOCK)
ON i.[object_id] = s.[object_id] 
AND i.index_id = s.stats_id
INNER JOIN sys.dm_db_partition_stats AS st WITH (NOLOCK)
ON o.[object_id] = st.[object_id]
AND i.[index_id] = st.[index_id]
WHERE o.[type] IN ('U', 'V')
AND st.row_count > 0
ORDER BY STATS_DATE(i.[object_id], i.index_id) DESC OPTION (RECOMPILE);  

-- Helps discover possible problems with out-of-date statistics
-- Also gives you an idea which indexes are the most active



-- Get fragmentation info for all indexes above a certain size in the current database  (Query 47) (Index Fragmentation)
-- Note: This query could take some time on a very large database
SELECT DB_NAME(ps.database_id) AS [Database Name], OBJECT_NAME(ps.OBJECT_ID) AS [Object Name], 
i.name AS [Index Name], ps.index_id, ps.index_type_desc, ps.avg_fragmentation_in_percent, 
ps.fragment_count, ps.page_count, i.fill_factor
FROM sys.dm_db_index_physical_stats(DB_ID(),NULL, NULL, NULL , N'LIMITED') AS ps
INNER JOIN sys.indexes AS i WITH (NOLOCK)
ON ps.[object_id] = i.[object_id] 
AND ps.index_id = i.index_id
WHERE ps.database_id = DB_ID()
AND ps.page_count > 2500
ORDER BY ps.avg_fragmentation_in_percent DESC OPTION (RECOMPILE);

-- Helps determine whether you have framentation in your relational indexes
-- and how effective your index maintenance strategy is


--- Index Read/Write stats (all tables in current DB) ordered by Reads  (Query 48) (Overall Index Usage - Reads)
SELECT OBJECT_NAME(s.[object_id]) AS [ObjectName], i.name AS [IndexName], i.index_id,
	   user_seeks + user_scans + user_lookups AS [Reads], s.user_updates AS [Writes],  
	   i.type_desc AS [IndexType], i.fill_factor AS [FillFactor]
FROM sys.dm_db_index_usage_stats AS s WITH (NOLOCK)
INNER JOIN sys.indexes AS i WITH (NOLOCK)
ON s.[object_id] = i.[object_id]
WHERE OBJECTPROPERTY(s.[object_id],'IsUserTable') = 1
AND i.index_id = s.index_id
AND s.database_id = DB_ID()
ORDER BY user_seeks + user_scans + user_lookups DESC OPTION (RECOMPILE); -- Order by reads

-- Show which indexes in the current database are most active for Reads


--- Index Read/Write stats (all tables in current DB) ordered by Writes  (Query 49) (Overall Index Usage - Writes)
SELECT OBJECT_NAME(s.[object_id]) AS [ObjectName], i.name AS [IndexName], i.index_id,
	   s.user_updates AS [Writes], user_seeks + user_scans + user_lookups AS [Reads], 
	   i.type_desc AS [IndexType], i.fill_factor AS [FillFactor],
	   s.last_system_update, s.last_user_update
FROM sys.dm_db_index_usage_stats AS s WITH (NOLOCK)
INNER JOIN sys.indexes AS i WITH (NOLOCK)
ON s.[object_id] = i.[object_id]
WHERE OBJECTPROPERTY(s.[object_id],'IsUserTable') = 1
AND i.index_id = s.index_id
AND s.database_id = DB_ID()
ORDER BY s.user_updates DESC OPTION (RECOMPILE);						 -- Order by writes

-- Show which indexes in the current database are most active for Writes


-- Get lock waits for current database (Query 50) (Lock Waits)
SELECT o.name AS [table_name], i.name AS [index_name], ios.index_id, ios.partition_number,
		SUM(ios.row_lock_wait_count) AS [total_row_lock_waits], 
		SUM(ios.row_lock_wait_in_ms) AS [total_row_lock_wait_in_ms],
		SUM(ios.page_lock_wait_count) AS [total_page_lock_waits],
		SUM(ios.page_lock_wait_in_ms) AS [total_page_lock_wait_in_ms],
		SUM(ios.page_lock_wait_in_ms)+ SUM(row_lock_wait_in_ms) AS [total_lock_wait_in_ms]
FROM sys.dm_db_index_operational_stats(DB_ID(), NULL, NULL, NULL) AS ios
INNER JOIN sys.objects AS o WITH (NOLOCK)
ON ios.[object_id] = o.[object_id]
INNER JOIN sys.indexes AS i WITH (NOLOCK)
ON ios.[object_id] = i.[object_id] 
AND ios.index_id = i.index_id
WHERE o.[object_id] > 100
GROUP BY o.name, i.name, ios.index_id, ios.partition_number
HAVING SUM(ios.page_lock_wait_in_ms)+ SUM(row_lock_wait_in_ms) > 0
ORDER BY total_lock_wait_in_ms DESC OPTION (RECOMPILE);

-- This query is helpful for troubleshooting blocking and deadlocking issues


-- Look at recent Full backups for the current database (Query 51) (Recent Full Backups)
SELECT TOP (30) bs.server_name, bs.database_name AS [Database Name], 
CONVERT (BIGINT, bs.backup_size / 1048576 ) AS [Backup Size (MB)],
DATEDIFF (SECOND, bs.backup_start_date, bs.backup_finish_date) AS [Backup Elapsed Time (sec)],
bs.backup_finish_date AS [Backup Finish Date]
FROM msdb.dbo.backupset AS bs WITH (NOLOCK)
WHERE DATEDIFF (SECOND, bs.backup_start_date, bs.backup_finish_date) > 0 
AND bs.backup_size > 0
AND bs.type = 'D' -- Change to L if you want Log backups
AND database_name = DB_NAME(DB_ID())
ORDER BY bs.backup_finish_date DESC OPTION (RECOMPILE);

-- Are your backup sizes and times changing over time?



-- These three Pluralsight Courses go into more detail about how to run these queries and interpret the results

-- SQL Server 2014 DMV Diagnostic Queries � Part 1 
-- http://www.pluralsight.com/courses/sql-server-2014-dmv-diagnostic-queries-part1

-- SQL Server 2014 DMV Diagnostic Queries � Part 2
-- http://www.pluralsight.com/courses/sql-server-2014-dmv-diagnostic-queries-part2

-- SQL Server 2014 DMV Diagnostic Queries � Part 3
-- http://www.pluralsight.com/courses/sql-server-2014-dmv-diagnostic-queries-part3




