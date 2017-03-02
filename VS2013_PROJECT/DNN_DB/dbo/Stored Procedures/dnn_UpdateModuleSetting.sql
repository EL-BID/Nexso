CREATE PROCEDURE [dbo].[dnn_UpdateModuleSetting]
	@ModuleId				int,
	@SettingName			nvarchar(50),
	@SettingValue			nvarchar(max),
	@LastModifiedByUserID  	int
AS
	UPDATE 	dbo.dnn_ModuleSettings
		SET 	SettingValue = @SettingValue,
				LastModifiedByUserID = @LastModifiedByUserID,
				LastModifiedOnDate = getdate()
		WHERE ModuleId = @ModuleId
		AND SettingName = @SettingName

