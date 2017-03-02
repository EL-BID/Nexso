create procedure [dbo].[dnn_DeleteModule]

@ModuleId   int

as

delete
from   dbo.dnn_Modules 
where  ModuleId = @ModuleId

