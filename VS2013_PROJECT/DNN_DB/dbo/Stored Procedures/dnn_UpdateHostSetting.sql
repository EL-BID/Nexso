CREATE PROCEDURE [dbo].[dnn_UpdateHostSetting]
	@SettingName			nvarchar(50),
	@SettingValue			nvarchar(256),
	@SettingIsSecure		bit,
	@LastModifiedByUserID	int
AS
	UPDATE dnn_HostSettings
		SET    
			SettingValue = @SettingValue, 
			SettingIsSecure = @SettingIsSecure,
			[LastModifiedByUserID] = @LastModifiedByUserID,	
			[LastModifiedOnDate] = getdate()
	WHERE  SettingName = @SettingName

