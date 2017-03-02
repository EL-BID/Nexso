CREATE PROCEDURE [dbo].[dnn_DeletePortalSettings]
	@PortalID      Int,          -- Not Null
	@CultureCode   nVarChar(10)  -- Null|'' for all languages and neutral settings

AS
BEGIN
	DELETE FROM dbo.[dnn_PortalSettings]
	 WHERE (PortalID    = @PortalID)
	   AND (CultureCode = @CultureCode OR IsNull(@CultureCode, '') = '')
END

