CREATE PROCEDURE [dbo].[dnn_RestoreTabModule]
	@TabId      int,
	@ModuleId   int
AS
	UPDATE dbo.dnn_TabModules
		SET IsDeleted = 0,
			VersionGuid = newId()
	WHERE  TabId = @TabId
		AND    ModuleId = @ModuleId

