CREATE PROCEDURE [dbo].[dnn_UpdateModuleOrder]
	@TabId              int,
	@ModuleId           int,
	@ModuleOrder        int,
	@PaneName           nvarchar(50)
AS
	UPDATE dbo.dnn_TabModules
		SET	ModuleOrder = @ModuleOrder,
			PaneName = @PaneName,
			VersionGuid = newId()
	WHERE TabId = @TabId
		AND ModuleId = @ModuleId

