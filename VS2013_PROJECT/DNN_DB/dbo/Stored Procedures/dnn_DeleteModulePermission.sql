CREATE PROCEDURE [dbo].[dnn_DeleteModulePermission]
	@ModulePermissionID int
AS

DELETE FROM dbo.dnn_ModulePermission
WHERE
	[ModulePermissionID] = @ModulePermissionID

