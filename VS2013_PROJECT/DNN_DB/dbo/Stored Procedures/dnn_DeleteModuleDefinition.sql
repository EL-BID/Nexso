CREATE PROCEDURE [dbo].[dnn_DeleteModuleDefinition]
	@ModuleDefId int
AS

-- delete custom permissions
DELETE FROM dbo.dnn_Permission
WHERE moduledefid = @ModuleDefId
	
DELETE FROM dbo.dnn_ModuleDefinitions
WHERE  ModuleDefId = @ModuleDefId

