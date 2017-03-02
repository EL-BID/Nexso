CREATE PROCEDURE [dbo].[dnn_DeletePortalSetting]
	@PortalID      Int,          -- Not Null
	@SettingName   nVarChar(50), -- Not Null
	@CultureCode   nVarChar(10)  -- Null|'' for all languages and neutral settings
AS
BEGIN
	DELETE FROM dbo.[dnn_PortalSettings]
	 WHERE (PortalID    = @PortalID)
	   AND (SettingName = @SettingName)
	   AND (CultureCode = @CultureCode OR IsNull(@CultureCode, '') = '')
END

