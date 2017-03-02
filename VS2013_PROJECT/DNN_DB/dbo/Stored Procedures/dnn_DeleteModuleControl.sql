create procedure [dbo].[dnn_DeleteModuleControl]

@ModuleControlId int

as

delete
from   dbo.dnn_ModuleControls
where  ModuleControlId = @ModuleControlId

