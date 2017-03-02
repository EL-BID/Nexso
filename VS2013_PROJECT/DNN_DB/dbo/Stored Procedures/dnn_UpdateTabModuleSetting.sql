CREATE PROCEDURE [dbo].[dnn_UpdateTabModuleSetting]
	@TabModuleId			int,
	@SettingName			nvarchar(50),
	@SettingValue			nvarchar(max),
	@LastModifiedByUserID	int

AS
	UPDATE dbo.dnn_TabModuleSettings
		SET    SettingValue = @SettingValue,
			   LastModifiedByUserID = @LastModifiedByUserID,
			   LastModifiedOnDate = getdate()
		WHERE  TabModuleId = @TabModuleId
		AND    SettingName = @SettingName

