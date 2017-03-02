CREATE PROCEDURE [dbo].[dnn_UpdateTabSetting]
	@TabID					INT,
	@SettingName			NVARCHAR(50),
	@SettingValue			NVARCHAR(2000),
	@LastModifiedByUserID  	INT
AS

	UPDATE 	dbo.dnn_TabSettings
	SET 	SettingValue = @SettingValue,
			LastModifiedByUserID = @LastModifiedByUserID,
			LastModifiedOnDate = GETDATE()
	WHERE TabID = @TabID
		AND SettingName = @SettingName

