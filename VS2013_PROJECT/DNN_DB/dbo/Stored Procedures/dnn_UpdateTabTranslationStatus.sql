CREATE PROCEDURE [dbo].[dnn_UpdateTabTranslationStatus]
	@TabId					int,
    @LocalizedVersionGuid	uniqueidentifier,
	@LastModifiedByUserID	int
AS
	UPDATE dbo.dnn_Tabs
		SET
		LocalizedVersionGuid	= @LocalizedVersionGuid,
		LastModifiedByUserID	= @LastModifiedByUserID,
		LastModifiedOnDate		= getdate()
	WHERE  TabId = @TabId

