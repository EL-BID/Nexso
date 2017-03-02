CREATE PROCEDURE [dbo].[dnn_UpdateModuleLastContentModifiedOnDate]
    @ModuleID	int
AS
    UPDATE dbo.dnn_Modules
        SET    LastContentModifiedOnDate = GETDATE()
    WHERE  ModuleID = @ModuleID

