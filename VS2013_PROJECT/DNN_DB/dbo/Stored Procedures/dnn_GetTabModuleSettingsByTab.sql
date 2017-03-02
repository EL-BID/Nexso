CREATE PROCEDURE [dbo].[dnn_GetTabModuleSettingsByTab]
    @TabId Int
AS
	BEGIN
		SELECT
			TMS.TabModuleID,
			TMS.SettingName,
			CASE WHEN Lower(TMS.SettingValue) LIKE 'fileid=%'
				 THEN dbo.dnn_FilePath(TMS.SettingValue)
				 ELSE TMS.SettingValue END           
				 AS SettingValue
		FROM   dbo.[dnn_TabModuleSettings] TMS
			INNER JOIN dbo.[dnn_TabModules] TM ON TMS.TabModuleID = TM.TabModuleID
		WHERE  TM.TabID = @TabId
		ORDER BY TMS.TabModuleID
	END

