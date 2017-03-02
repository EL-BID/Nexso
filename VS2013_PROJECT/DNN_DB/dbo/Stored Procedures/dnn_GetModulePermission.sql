CREATE PROCEDURE [dbo].[dnn_GetModulePermission]
	
	@ModulePermissionID int

AS
SELECT *
FROM dbo.dnn_vw_ModulePermissions
WHERE ModulePermissionID = @ModulePermissionID

