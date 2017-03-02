CREATE PROCEDURE [dbo].[dnn_UpdateTabModuleVersionByModule]
    @ModuleID	int
AS
    UPDATE dbo.dnn_TabModules
        SET    VersionGuid = NEWID()
    WHERE  ModuleID = @ModuleID

