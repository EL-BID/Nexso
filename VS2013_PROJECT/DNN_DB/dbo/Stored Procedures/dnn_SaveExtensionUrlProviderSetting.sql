CREATE PROCEDURE [dbo].[dnn_SaveExtensionUrlProviderSetting] 
	@ExtensionUrlProviderID		int,
	@PortalId					int,
	@SettingName				nvarchar(100),
	@SettingValue				nvarchar(2000)
AS

	IF (SELECT COUNT(*) 
			FROM dbo.dnn_ExtensionUrlProviderSetting 
			WHERE ExtensionUrlProviderID = @ExtensionUrlProviderID
				AND PortalID = @PortalId
				AND SettingName = @SettingName) = 0
		BEGIN
			--ADD
			INSERT INTO dbo.dnn_ExtensionUrlProviderSetting
			        ( ExtensionUrlProviderID ,
			          PortalID ,
			          SettingName ,
			          SettingValue
			        )
			VALUES  ( @ExtensionUrlProviderID , -- ExtensionUrlProviderID - int
			          @PortalId , -- PortalID - int
			          @SettingName , -- SettingName - nvarchar(100)
			          @SettingValue  -- SettingValue - nvarchar(2000)
			        )
		END
	ELSE
		BEGIN
			UPDATE dbo.dnn_ExtensionUrlProviderSetting	
				SET 
					SettingValue = @SettingValue
				WHERE ExtensionUrlProviderID = @ExtensionUrlProviderID
					AND PortalID = @PortalId
					AND SettingName = @SettingName
		END

