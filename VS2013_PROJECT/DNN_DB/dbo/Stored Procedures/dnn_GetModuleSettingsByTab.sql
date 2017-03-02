CREATE PROCEDURE [dbo].[dnn_GetModuleSettingsByTab]
    @TabId Int
AS
	BEGIN
		SELECT
			MS.ModuleID,
			MS.SettingName,
			CASE WHEN Lower(MS.SettingValue) LIKE 'fileid=%'
				 THEN dbo.dnn_FilePath(MS.SettingValue)
				 ELSE MS.SettingValue END           
				 AS SettingValue
		FROM   dbo.[dnn_ModuleSettings] MS
			INNER JOIN dbo.[dnn_TabModules] TM ON MS.ModuleID = TM.ModuleID
		WHERE  TM.TabID = @TabId
		ORDER BY MS.ModuleID
	END

