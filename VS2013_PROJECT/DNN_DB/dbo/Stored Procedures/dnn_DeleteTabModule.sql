CREATE PROCEDURE [dbo].[dnn_DeleteTabModule]
	@TabId      int,
	@ModuleId   int,
	@SoftDelete	bit
AS
IF @SoftDelete = 1
	UPDATE dbo.dnn_TabModules
		SET	IsDeleted = 1,
			VersionGuid = newId(),
			LastModifiedOnDate=GETDATE()
	WHERE  TabId = @TabId
		AND    ModuleId = @ModuleId
ELSE
	DELETE
	FROM   dbo.dnn_TabModules 
	WHERE  TabId = @TabId
		AND    ModuleId = @ModuleId

