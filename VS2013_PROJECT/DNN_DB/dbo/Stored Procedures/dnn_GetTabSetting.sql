CREATE PROCEDURE [dbo].[dnn_GetTabSetting]

    @TabId         Int,         -- not null!
    @SettingName   nVarChar(50) -- not null or empty!

AS
	BEGIN
		SELECT
			TS.SettingName,
			CASE WHEN TS.SettingValue LIKE 'fileid%'
				 THEN dbo.dnn_FilePath(TS.SettingValue)
				 ELSE TS.SettingValue  END AS SettingValue
		FROM dbo.[dnn_TabSettings] TS
		WHERE  TabID = @TabId AND SettingName = @SettingName
	END

