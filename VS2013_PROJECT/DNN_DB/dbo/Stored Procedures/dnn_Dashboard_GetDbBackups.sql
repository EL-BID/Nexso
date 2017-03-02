CREATE PROCEDURE [dbo].[dnn_Dashboard_GetDbBackups]
AS
	DECLARE @ProductEdition INT
	SET @ProductEdition = CAST(ServerProperty('EngineEdition') as INT)

	IF (@ProductEdition = 5) --Check for SQL Azure
	BEGIN
		SELECT      
			'Unsupported' as name, 
			NULL as StartDate, 
			NULL as FinishDate, 
			0 as size, 
			NULL as database_name, 
			'UNKNOWN' as BackupType
	END
	ELSE
	BEGIN
		EXEC('SELECT TOP 20     
				name, 
				backup_start_date as StartDate, 
				backup_finish_date as FinishDate, 
				backup_size/1024 as size, 
				database_name, 
				CASE type
					WHEN ''D'' THEN ''Database''
					WHEN ''I'' THEN ''Differential database''
					WHEN ''L'' THEN ''Log''
					WHEN ''F'' THEN ''File or filegroup''
					WHEN ''G'' THEN ''Differential file''
					WHEN ''P'' THEN ''Partial''
					WHEN ''Q'' THEN ''Differential partial''
				END AS BackupType
				FROM         
				msdb..backupset
				WHERE
				database_name = DB_NAME() 
				ORDER BY backup_start_date DESC')
	END

