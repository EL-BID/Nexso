CREATE PROCEDURE [dbo].[dnn_GetTabModuleSettings]
    @TabModuleId Int -- Null: all tabmodules
AS
	BEGIN
		SELECT
			TMS.SettingName,
			CASE WHEN Lower(TMS.SettingValue) LIKE 'fileid=%'
				 THEN dbo.dnn_FilePath(TMS.SettingValue)
				 ELSE TMS.SettingValue END           AS SettingValue
		FROM   dbo.[dnn_TabModuleSettings] TMS
		WHERE  TabModuleID = @TabModuleId OR IsNull(@TabModuleId, -1) = -1
		OPTION (OPTIMIZE FOR (@TabModuleId UNKNOWN))
	END

