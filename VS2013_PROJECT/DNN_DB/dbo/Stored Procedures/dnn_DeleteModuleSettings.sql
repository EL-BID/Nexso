create procedure [dbo].[dnn_DeleteModuleSettings]
@ModuleId      int
as

DELETE FROM dbo.dnn_ModuleSettings 
WHERE ModuleId = @ModuleId

