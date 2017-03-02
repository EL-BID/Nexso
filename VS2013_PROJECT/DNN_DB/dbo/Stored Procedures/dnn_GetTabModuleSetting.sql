CREATE PROCEDURE [dbo].[dnn_GetTabModuleSetting]
    @TabModuleId   Int,              -- not null!
    @SettingName   nVarChar(50)      -- not null or empty!
AS
	BEGIN
		SELECT
			TMS.SettingName,
			CASE WHEN TMS.SettingValue LIKE 'fileid%'
				 THEN dbo.dnn_FilePath(TMS.SettingValue)
				 ELSE TMS.SettingValue  END AS SettingValue
		FROM dbo.[dnn_TabModuleSettings] TMS
		WHERE  TabModuleID = @TabModuleId AND SettingName = @SettingName
	END

