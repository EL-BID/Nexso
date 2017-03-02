CREATE PROCEDURE [dbo].[dnn_Dashboard_GetDbFileInfo]
AS
	IF OBJECT_ID('sys.database_files') IS NULL
		BEGIN
		SELECT 'Total Size' AS FileType,
					'Total' AS Name,
					SUM(reserved_page_count)*8 AS Size,
					'n/a' AS FileName
				FROM sys.dm_db_partition_stats
		END
	ELSE
		BEGIN
			SELECT	CASE LOWER(RIGHT(physical_name,3))
						WHEN 'mdf' THEN 'DATA'
						WHEN 'ldf' THEN 'LOG'
						ELSE 'UNKNOWN'
					END as FileType,
						name AS Name,
						size*8 AS Size,
						physical_name AS FileName
					FROM sys.database_files
		END

