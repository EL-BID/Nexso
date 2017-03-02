create procedure [dbo].[dnn_DeleteTabModuleSettings]
@TabModuleId      int
as

DELETE FROM dbo.dnn_TabModuleSettings 
WHERE TabModuleId = @TabModuleId

