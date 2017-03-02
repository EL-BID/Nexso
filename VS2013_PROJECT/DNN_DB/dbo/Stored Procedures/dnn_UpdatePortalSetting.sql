CREATE PROCEDURE [dbo].[dnn_UpdatePortalSetting]
	@PortalID       Int,			-- Key, Not Null
	@SettingName    nVarChar(  50), -- Key, not Null or Empty
	@SettingValue   nVarChar(2000), -- Not Null
	@UserID			Int,			-- Not Null (editing user)
	@CultureCode    nVarChar(  10)  -- Key, Null|'' for neutral language 
AS
BEGIN
	IF IsNull(@SettingValue, '') = ''
		DELETE FROM dbo.dnn_PortalSettings 
		 WHERE PortalID    = @PortalID
		   AND SettingName = @SettingName 
		   AND IsNull(CultureCode, '') = IsNull(@CultureCode, '')
	ELSE IF EXISTS (SELECT * FROM dbo.dnn_PortalSettings 
	                    WHERE PortalID    = @PortalID
						  AND SettingName = @SettingName 
						  AND IsNull(CultureCode, '') = IsNull(@CultureCode, '')) 
		UPDATE dbo.dnn_PortalSettings
		 SET   [SettingValue]         = @SettingValue,
			   [LastModifiedByUserID] = @UserID,
			   [LastModifiedOnDate]   = GetDate()
		 WHERE [PortalID]              = @PortalID
		   AND [SettingName]           = @SettingName
		   AND IsNull(CultureCode, '') = IsNull(@CultureCode, '') 		   
	ELSE IF IsNull(@SettingName,'') != '' -- Add new record:
		INSERT INTO dbo.dnn_PortalSettings 
		           ( PortalID,  SettingName,  SettingValue, CreatedByUserID, CreatedOnDate, LastModifiedByUserID, LastModifiedOnDate, CultureCode) 
			VALUES (@PortalID, @SettingName, @SettingValue, @UserID,         GetDate(),     @UserID ,             GetDate(),          CASE WHEN @CultureCode = '' THEN Null ELSE @CultureCode END)
END

