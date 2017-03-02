CREATE PROCEDURE [dbo].[dnn_GetModuleSettings]
    @ModuleId Int -- Null: settings from all modules
AS
	BEGIN
		SELECT
			MS.SettingName,
			CASE WHEN Lower(MS.SettingValue) LIKE 'fileid=%'
				 THEN dbo.dnn_FilePath(MS.SettingValue)
				 ELSE MS.SettingValue END           AS SettingValue
		FROM   dbo.[dnn_ModuleSettings] MS
		WHERE  ModuleID = @ModuleId or IsNull(@ModuleId, -1) = -1
		OPTION (OPTIMIZE FOR (@ModuleId UNKNOWN))
	END

