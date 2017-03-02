CREATE PROCEDURE [dbo].[dnn_UpdateTabModuleTranslationStatus]
	@TabModuleId			int,
    @LocalizedVersionGuid	uniqueidentifier,
	@LastModifiedByUserID	int
AS
	UPDATE dbo.dnn_TabModules
		SET
		LocalizedVersionGuid	= @LocalizedVersionGuid,
		LastModifiedByUserID	= @LastModifiedByUserID,
		LastModifiedOnDate		= getdate()
	WHERE  TabModuleId = @TabModuleId

