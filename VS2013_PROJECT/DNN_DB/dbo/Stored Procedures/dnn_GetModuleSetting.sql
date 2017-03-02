CREATE PROCEDURE [dbo].[dnn_GetModuleSetting]
    @ModuleId      Int,          -- not null!
    @SettingName   nVarChar(50)  -- not null or empty!
AS
	BEGIN
		SELECT
			MS.SettingName,
			CASE WHEN Lower(MS.SettingValue) LIKE 'fileid=%'
				 THEN dbo.dnn_FilePath(MS.SettingValue)
				 ELSE MS.SettingValue  END AS SettingValue
		FROM dbo.[dnn_ModuleSettings] MS
		WHERE  ModuleID = @ModuleId AND SettingName = @SettingName
	END

